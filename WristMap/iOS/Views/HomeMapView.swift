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
                        let formattedDistance = String(format: "%.0f km", distanceMarker.distance)
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
    }
}

struct RouteDistanceMarker: Identifiable {
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
