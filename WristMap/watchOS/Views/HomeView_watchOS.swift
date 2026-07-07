//
//  HomeView_watchOS.swift
//  WristMap Watch App Watch App
//

import SwiftUI
import MapKit
import CoreLocation

struct HomeView_watchOS: View {
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @State private var trackingMode: UserTrackingModes = .follow
    
    @StateObject private var watchSession = WatchSessionManager()
    @State private var points: [GPXPoint] = []
    @State private var isRouteRecenterActive: Bool = false
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                UserAnnotation()
                if points.count >  1 {
                    MapPolyline(coordinates: points.map(\.coordinate))
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .onChange(of: watchSession.receivedFile) {
                guard let url = watchSession.receivedFile else { return }
                
                do {
                    try points = GPXParser().parse(url: url)
                } catch {
                    print(error)
                }
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .onChange(of: position) {_, newValue in
                if newValue.positionedByUser {
                    isRouteRecenterActive = false
                    trackingMode = .none
                }
            }
            .toolbar {
                // location
                ToolbarItem(placement: .topBarLeading) {
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
        }
    }
    
    private func recenterOnRoute() {
        var rect = MKMapRect.null
        trackingMode = .none
        
        for point in points {
            rect = rect.union(
                MKMapRect(
                    origin: MKMapPoint(point.coordinate),
                    size: MKMapSize(width: 1, height: 1)
                )
            )
        }
        
        withAnimation(.easeInOut) {
            position = .rect(rect)
        }
        
        isRouteRecenterActive = true
    }
}

#Preview {
    HomeView_watchOS()
}
