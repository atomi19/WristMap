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
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
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
            .mapControls {
                MapUserLocationButton()
                MapScaleView()
            }
            .mapStyle(selectedMapStyle.mapStyle)
            .onChange(of: selectedMapStyle) {
                Settings.mapStyle = selectedMapStyle
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
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
                    onRouteTap: { gpxPoints in
                        self.points = gpxPoints
                        isShowingRoutesLibrary = false
                    }
                )
            }
        }
    }
}

#Preview {
    HomeView_iOS()
}
