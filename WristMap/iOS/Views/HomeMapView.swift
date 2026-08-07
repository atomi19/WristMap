//
//  HomeMapView.swift
//  WristMap
//

import SwiftUI
import MapKit

struct HomeMapView: View {
    @ObservedObject var tracker: LocationTracker
    @Binding var position: MapCameraPosition
    
    let points: [GPXPoint]
    let sessionPoints: [CLLocation]
    let trackingPoints: [CLLocation]
    let routeDistanceMarkers: [RouteDistanceMarker]
    
    @Binding var selectedMapStyle: SelectedMapStyle
    @Binding var activeSheet: ActiveSheet?
    @Binding var trackingMode: UserTrackingModes
    
    @State private var currentCamera: MapCamera?
    
    var body: some View {
        Map(position: $position) {
            // user location
            UserAnnotation()
            // gpx route
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
                        let formattedDistance = DataFormatter.distance(distanceMarker.distance)
                        Annotation("", coordinate: distanceMarker.coordinate) {
                            RouteDistanceMarkerView(textLabel: formattedDistance)
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
            // user tracking route
            if !tracker.locationHistory.isEmpty {
                MapPolyline(coordinates: tracker.locationHistory.map(\.coordinate))
                    .stroke(.red, lineWidth: 4)
            }
            // user session points
            if sessionPoints.count > 1 {
                MapPolyline(coordinates: sessionPoints.map { $0.coordinate })
                    .stroke(.green, lineWidth: 4)
            }
        }
        .mapControls {
            MapScaleView()
        }
        .mapStyle(selectedMapStyle.mapStyle)
        .onMapCameraChange(frequency: .continuous) { context in
            currentCamera = context.camera
        }
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // menu
                MoreMenuView(
                    selectedMapStyle: $selectedMapStyle,
                    activeSheet: $activeSheet
                )
                // user location
                CustomUserLocationButton(
                    position: $position,
                    userTrackingMode: $trackingMode
                )
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                if let currentCamera, currentCamera.heading != 0 {
                    CustomCompassButton(
                        heading: currentCamera.heading,
                        resetHeading: {
                            var camera = currentCamera
                            camera.heading = 0
                            
                            withAnimation(.easeInOut) {
                                position = .camera(camera)
                            }
                        }
                    )
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding()
        }
    }
}

// distance annotations on route
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
