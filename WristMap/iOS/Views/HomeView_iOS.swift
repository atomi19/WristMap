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
    @State private var isRouteRecenterActive: Bool = false
    @State private var isShowingRouteDetails: Bool = false
    @State private var routeDetailsSelectedDetent: PresentationDetent = .height(75)
    
    // settings
    @State private var selectedMapStyle: SelectedMapStyle = Settings.mapStyle
    
    // route distance markers (km)
    @State private var routeDistanceMarkers: [RouteDistanceMarker] = []

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                // user location
                UserAnnotation()
                if points.count > 1 {
                    // route
                    MapPolyline(coordinates: points.map(\.coordinate))
                        .stroke(.blue, lineWidth: 4)
                    // start annotation marker
                    if let point = points.first {
                        Annotation("", coordinate: point.coordinate) {
                            CustomAnnotationView(textLabel: "Start")
                        }
                    }
                    // distance annotations
                    if !routeDistanceMarkers.isEmpty {
                        ForEach(routeDistanceMarkers) { distanceMarker in
                            let formattedDistance = String(format: "%.0f", distanceMarker.distance)
                            Annotation("", coordinate: distanceMarker.coordinate) {
                                RouteDistanceMarkerView(textLabel: "\(formattedDistance) km")
                            }
                        }
                    }
                    // end annotation marker
                    if let point = points.last {
                        Annotation("", coordinate: point.coordinate) {
                            CustomAnnotationView(textLabel: "End")
                        }
                    }
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
                    calculateDistanceMarkers(route: route)
                    isShowingRouteDetails = true
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
                    isRouteRecenterActive = false
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
            .sheet(isPresented: $isShowingRouteDetails) {
                if let route = selectedRoute {                
                    RouteDetailsView(
                        route: route,
                        isRouteRecenterActive: $isRouteRecenterActive,
                        onClose: {
                            selectedRoute = nil
                            isShowingRouteDetails = false
                            points = []
                        },
                        onRouteRecenter: recenterOnRoute,
                        selectedDetents: routeDetailsSelectedDetent,
                        points: points
                    )
                    .presentationDetents(
                        [
                            .height(75),
                            .height(225)
                        ],
                        selection: $routeDetailsSelectedDetent
                    )
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(225)))
                    .interactiveDismissDisabled()
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
    
    // calculate coordinates for distance markers on route
    private func calculateDistanceMarkers(route: Route) {
        let totalDistance = route.distance / 1000
        
        let targetMarkers = 10.0
        let rawInterval = totalDistance / targetMarkers
        
        let niceIntervals: [Double] = [
            1, 2, 5, 10, 20, 25, 50, 100
        ]
        
        let interval = niceIntervals.first(where: { $0 >= rawInterval }) ?? 100
        
        // count from interval by interval to total route distance
        let markerDistances = Array(
            stride(
                from: interval,
                to: totalDistance,
                by: interval
            )
        )
        
        var markerIndex = 0
        var distance: Double = 0
        routeDistanceMarkers.removeAll()
        
        // go through GPX points
        // and add distance marker if a target distance is reached
        for i in 1..<points.count {
            let start = CLLocation(
                latitude: points[i - 1].coordinate.latitude,
                longitude: points[i - 1].coordinate.longitude
            )
            
            let end = CLLocation(
                latitude: points[i].coordinate.latitude,
                longitude: points[i].coordinate.longitude
            )
            
            distance += start.distance(from: end)
            
            while markerIndex < markerDistances.count &&
                    distance >= markerDistances[markerIndex] * 1000 {
                routeDistanceMarkers.append(
                    RouteDistanceMarker(
                        distance: markerDistances[markerIndex],
                        coordinate: points[i].coordinate
                    )
                )
                
                markerIndex += 1
            }
        }
    }
}

private struct RouteDistanceMarker: Identifiable {
    let id = UUID()
    let distance: Double // distance in km
    let coordinate: CLLocationCoordinate2D
}

// km annotations on route
private struct RouteDistanceMarkerView: View {
    let textLabel: String
    
    var body: some View {
        Text(textLabel)
            .font(.caption2)
            .foregroundStyle(.primary)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3)
    }
}

// start and end route annotations
private struct CustomAnnotationView: View {
    let textLabel: String
    
    var body: some View {
        Text(textLabel)
            .font(.caption.weight(.bold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3)
    }
}

#Preview {
    HomeView_iOS()
}
