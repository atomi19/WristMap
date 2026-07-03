//
//  HomeView_watchOS.swift
//  WristMap Watch App Watch App
//

import SwiftUI
import MapKit
import CoreLocation

struct HomeView_watchOS: View {
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    @StateObject private var watchSession = WatchSessionManager()
    @State private var points: [GPXPoint] = []
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
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
            .mapControls {
                MapUserLocationButton()
            }
        }
    }
}

#Preview {
    HomeView_watchOS()
}
