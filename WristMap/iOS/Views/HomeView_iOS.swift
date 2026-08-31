//
//  ContentView.swift
//  WristMap
//

import SwiftUI
import MapKit
internal import UniformTypeIdentifiers
import CoreLocation
import Foundation
import SwiftData

enum ActiveSheet: Identifiable {
    var id: Self { self }
    
    case settings
    case library
    case routeDetails
    case sessionRecord
    case sessionDetails
}

struct HomeView_iOS: View {
    @Environment(\.modelContext) private var context
    
    @StateObject private var tracker = LocationTracker()
    @State private var viewModel = HomeViewModel()
    @State private var sessionManager = SessionManager()
    
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: UserTrackingModes = .follow
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    @State private var isRouteRecenterActive: Bool = false
    
    // sheets
    @State private var activeSheet: ActiveSheet?
    
    @State private var routeDetailsDetent: PresentationDetent = SheetDetent.compact
    @State private var sessionRecordDetent: PresentationDetent = SheetDetent.compact
    @State private var sessionDetailsDetent: PresentationDetent = SheetDetent.compact
    // if session recording is active, open it back
    @State private var shouldOpenSessionRecordBack: Bool = false
    
    // sessions
    @Query(sort: \Session.startedAt, order: .reverse)
    private var sessions: [Session]
    
    // settings
    @State private var selectedMapStyle: SelectedMapStyle = Settings.mapStyle
    
    // app theme
    @AppStorage(Settings.Keys.appTheme)
    private var appThemeRawValue = AppTheme.system.rawValue
    
    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .system
    }

    var body: some View {
        NavigationStack {
            HomeMapView(
                tracker: tracker,
                position: $position,
                points: viewModel.points,
                sessionPoints: sessionManager.sessionPoints,
                trackingPoints: tracker.locationHistory,
                routeDistanceMarkers: viewModel.routeDistanceMarkers,
                selectedMapStyle: $selectedMapStyle,
                activeSheet: $activeSheet,
                trackingMode: $trackingMode
            )
            .task(id: viewModel.selectedRoute?.uuid) {
                guard let route = viewModel.selectedRoute else {
                    viewModel.points = []
                    return
                }
                
                do {
                    try viewModel.loadRoute(route)
                    activeSheet = .routeDetails
                } catch {
                    viewModel.points = []
                    print(error)
                }
            }
            .onChange(of: selectedMapStyle) {
                Settings.mapStyle = selectedMapStyle
            }
            .onChange(of: position) { _ , newValue in
                if newValue.positionedByUser {
                    isRouteRecenterActive = false
                    trackingMode = .none
                }
            }
            .onChange(of: tracker.locationHistory) { oldValue, newValue in
                guard newValue.count > oldValue.count else { return }
                
                sessionManager.recordNewPoints(
                    newLocations: Array(newValue[oldValue.count...]),
                    context: context
                )
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                
                // restore last session if it is uncompleted (finishedAt == nil)
                if sessionManager.restoreActiveSession(from: sessions) {
                    tracker.locationHistory = sessionManager.sessionPoints
                    activeSheet = .sessionRecord
                }
            }
            .sheet(
                item: $activeSheet,
                onDismiss: {
                    if activeSheet == nil {
                        if shouldOpenSessionRecordBack {
                            activeSheet = .sessionRecord
                        }
                    }
                }
            ) { sheet in
                sheetView(sheet: sheet)
                    .preferredColorScheme(appTheme.colorScheme)
            }
        }
    }
    
    @ViewBuilder
    private func sheetView(sheet: ActiveSheet) -> some View {
        switch sheet {
        case .settings:
            SettingsView()
        case .library:
            LibraryView(
                sessionManager: sessionManager,
                sessions: sessions,
                onRouteTap: { route in
                    viewModel.selectedRoute = route
                    activeSheet = nil
                },
                onSessionTap: { session in
                    sessionManager.select(session: session)
                    activeSheet = .sessionDetails
                }
            )
        case .routeDetails:
            if let route = viewModel.selectedRoute {
                RouteDetailsView(
                    route: route,
                    isRouteRecenterActive: $isRouteRecenterActive,
                    selectedDetents: $routeDetailsDetent,
                    points: viewModel.points,
                    onClose: {
                        viewModel.clearRoute()
                        activeSheet = nil
                    },
                    recenter: recenterOnRoute,
                )
            }
        case .sessionRecord:
            SessionRecordView(
                tracker: tracker,
                sessionManager: sessionManager,
                selectedDetents: $sessionRecordDetent,
                isSessionActive: $shouldOpenSessionRecordBack
            )
        case .sessionDetails:
            if let session = sessionManager.selectedSession {
                SessionDetailsView(
                    selectedDetents: $sessionDetailsDetent,
                    session: session,
                    isRouteRecenterActive: isRouteRecenterActive,
                    onClose: {
                        activeSheet = nil
                        sessionManager.sessionPoints.removeAll()
                    },
                    recenter: recenterOnRoute,
                )
            }
        }
    }
    
    private func recenterOnRoute(coordinates: [CLLocationCoordinate2D]) {
        MapRecenter.recenter(
            coordinates: coordinates,
            position: $position,
            trackingMode: $trackingMode,
            isRouteRecenterActive: $isRouteRecenterActive
        )
    }
}

#Preview {
    HomeView_iOS()
}
