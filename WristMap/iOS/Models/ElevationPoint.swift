//
//  ElevationPoint.swift
//  WristMap
//

import Foundation

struct ElevationPoint: Identifiable {
    var id = UUID()
    var distance: Double // in meters
    var elevation: Double // in meters
}
