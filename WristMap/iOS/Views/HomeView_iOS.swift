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
    @State private var selectedMapStyle: SelectedMapStyle = .standard
    @State private var isShowingRoutesLibrary = false

    var body: some View {
        NavigationStack {
            Map(position: $position) {
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

private enum SelectedMapStyle: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case imagery = "Satellite"
    case hybrid = "Hybrid"
    
    var id: String { self.rawValue }
    
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .imagery: return .imagery
        case .hybrid: return .hybrid
        }
    }
}

#Preview {
    HomeView_iOS()
}
