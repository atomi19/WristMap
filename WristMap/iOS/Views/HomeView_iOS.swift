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
    @StateObject private var tracker = LocationTracker()
    @State private var viewModel = HomeViewModel()
    
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
                sessionPoints: viewModel.sessionPoints,
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
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                
                // restore last session if it is uncompleted (finishedAt == nil)
                if viewModel.restoreActiveSession(from: sessions) {
                    tracker.locationHistory = viewModel.sessionPoints
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
                sessions: sessions,
                onRouteTap: { route in
                    viewModel.selectedRoute = route
                    activeSheet = nil
                },
                onSessionTap: { session in
                    viewModel.select(session: session)
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
                    recenter: recenter,
                )
            }
        case .sessionRecord:
            SessionRecordView(
                tracker: tracker,
                selectedDetents: $sessionRecordDetent,
                activeSession: $viewModel.selectedSession,
                isSessionRestored: $viewModel.isSessionRestored,
                isSessionActive: $shouldOpenSessionRecordBack
            )
        case .sessionDetails:
            if let session = viewModel.selectedSession {
                SessionDetailsView(
                    selectedDetents: $sessionDetailsDetent,
                    session: session,
                    isRouteRecenterActive: isRouteRecenterActive,
                    onClose: {
                        activeSheet = nil
                        viewModel.sessionPoints.removeAll()
                    },
                    recenter: recenter,
                )
            }
        }
    }
    
    private func recenter(coordinates: [CLLocationCoordinate2D]) {
        var rect = MKMapRect.null
        trackingMode = .none
        
        for coordinate in coordinates {
            rect = rect.union(
                MKMapRect(
                    origin: MKMapPoint(coordinate),
                    size: MKMapSize(width: 1, height: 1)
                )
            )
        }
        
        // add padding from the screen edges when recenter on route
        let paddingRect = rect.insetBy(
            dx: -rect.size.width * 0.2,
            dy: -rect.size.height * 0.2
        )
        
        withAnimation(.easeInOut) {
            position = .rect(paddingRect)
        }
        
        isRouteRecenterActive = true
    }
}

#Preview {
    HomeView_iOS()
}
