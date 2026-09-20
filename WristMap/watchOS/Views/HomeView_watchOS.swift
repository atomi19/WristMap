//
//  HomeView_watchOS.swift
//  WristMap Watch App Watch App
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct HomeView_watchOS: View {
    @Environment(\.modelContext) private var context
    @Environment(WatchConnectivityManager.self)
    private var watchConnectivityManager
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @State private var trackingMode: UserTrackingModes = .follow
    
    @State private var points: [GPXPoint] = []
    @State private var isRouteRecenterActive: Bool = false
    
    @StateObject private var tracker = LocationTracker()
    @State private var isShowingMoreMenuSheet: Bool = false
    
    @State private var sessionManager = SessionManager()
    
    // sessions
    @Query(sort: \Session.startedAt, order: .reverse)
    private var sessions: [Session]
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                UserAnnotation()
                if points.count >  1 {
                    MapPolyline(coordinates: points.map(\.coordinate))
                        .stroke(.blue, lineWidth: 4)
                }
                // session recording route
                if !tracker.locationHistory.isEmpty {
                    MapPolyline(coordinates: tracker.locationHistory.map(\.coordinate))
                        .stroke(.red, lineWidth: 4)
                }
            }
            .onChange(of: watchConnectivityManager.receivedFile) {
                guard let url = watchConnectivityManager.receivedFile else { return }
                
                do {
                    try points = GPXParser().parse(url: url)
                } catch {
                    print(error)
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
                
                // restore last session if it is uncompleted
                // so finishedAt == nil
                if sessionManager.restoreActiveSession(from: sessions) {
                    tracker.locationHistory = sessionManager.sessionPoints
                    tracker.restoreTracking()
                    sessionManager.isSessionActive = true
                    sessionManager.isSessionRestored = true
                    isShowingMoreMenuSheet = true
                }
            }
            .onChange(of: position) {_, newValue in
                if newValue.positionedByUser {
                    isRouteRecenterActive = false
                    trackingMode = .none
                }
            }
            .toolbar {
                // more menu
                ToolbarItem(placement: .topBarLeading) {
                    Button("Menu", systemImage: "line.horizontal.3") {
                        isShowingMoreMenuSheet = true
                    }
                }
                // location
                ToolbarItem(placement: .bottomBar) {
                    CustomUserLocationButton(
                        position: $position,
                        userTrackingMode: $trackingMode
                    )
                }
                // route recenter
                if points.count > 1 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            "Recenter",
                            systemImage: isRouteRecenterActive ? "map.fill" : "map",
                            action: recenterOnRoute
                        )
                    }
                }
            }
            .sheet(isPresented: $isShowingMoreMenuSheet) {
                MoreMenuView_watchOS(
                    tracker: tracker,
                    sessionManager: sessionManager,
                    sessions: sessions
                )
            }
        }
    }
    
    private func recenterOnRoute() {
        MapRecenter.recenter(
            coordinates: points.map(\.coordinate),
            position: $position,
            trackingMode: $trackingMode,
            isRouteRecenterActive: $isRouteRecenterActive
        )
    }
}

#Preview {
    HomeView_watchOS()
}
