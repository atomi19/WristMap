//
//  ContentView.swift
//  WristMap
//

import SwiftUI
import MapKit
internal import UniformTypeIdentifiers
import CoreLocation
import Foundation

struct HomeView_iOS: View {
    @State private var points: [GPXPoint] = []
    @State private var selectedRoute: Route? = nil
    
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: UserTrackingModes = .follow
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @State private var isShowingRoutesLibrary = false
    
    // settings
    @State private var selectedMapStyle: SelectedMapStyle = Settings.mapStyle

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                UserAnnotation()
                if points.count > 1 {
                    MapPolyline(coordinates: points.map(\.coordinate))
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .task(id: selectedRoute?.uuid) {
                guard let route = selectedRoute else {
                    points = []
                    return
                }
                
                do {
                    let url = GPXFileManager.fileURL(for: route.uuid)
                    points = try GPXParser().parse(url: url)
                } catch {
                    points = []
                    print(error)
                }
            }
            .mapControls {
                MapScaleView()
            }
            .mapStyle(selectedMapStyle.mapStyle)
            .onChange(of: selectedMapStyle) {
                Settings.mapStyle = selectedMapStyle
            }
            .onChange(of: position) {_, newValue in
                if newValue.positionedByUser {
                    trackingMode = .none
                }
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    CustomUserLocationButton(
                        position: $position,
                        userTrackingMode: $trackingMode
                    )
                    Menu {
                        Picker("Map Style", selection: $selectedMapStyle) {
                            ForEach(SelectedMapStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        Button("Routes", systemImage: "map") {
                            isShowingRoutesLibrary.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $isShowingRoutesLibrary) {
                RoutesLibraryView(
                    onRouteTap: { route in
                        self.selectedRoute = route
                        isShowingRoutesLibrary = false
                    }
                )
            }
            .safeAreaInset(edge: .bottom) {
                if let route = selectedRoute {
                    RouteInfoView(route: route) {
                        selectedRoute = nil
                        points = []
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView_iOS()
}
