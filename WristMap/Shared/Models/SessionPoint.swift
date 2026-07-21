//
//  SessionPoint.swift
//  WristMap
//

import Foundation
import SwiftData

@Model
final class SessionPoint {
    var latitude: Double
    var longitude: Double
    var elevation: Double
    var speed: Double
    var timestamp: Date
    
    init(latitude: Double, longitude: Double, elevation: Double, speed: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.speed = speed
        self.timestamp = timestamp
    }
}
