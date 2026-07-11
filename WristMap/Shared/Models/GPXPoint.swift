//
//  GPXPoint.swift
//  WristMap
//

import Foundation
import MapKit

struct GPXPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var elevation: Double?
}
