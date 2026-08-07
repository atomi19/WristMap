//
//  RouteDistanceMarker.swift
//  WristMap
//

import CoreLocation

struct RouteDistanceMarker: Identifiable {
    let id = UUID()
    let distance: Double // distance in meters
    let coordinate: CLLocationCoordinate2D
}
