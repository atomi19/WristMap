//
//  Tracking.swift
//  WristMap
//

import Foundation
import SwiftData
import CoreLocation

@Model
class Session {
    var uuid: UUID = UUID()
    var name: String = ""
    var sessionPoints: [SessionPoint] = []
    var distance: CLLocationDistance = 0
    var startedAt: Date
    var finishedAt: Date?
    var duration: TimeInterval = 0
    var movingDuration: TimeInterval = 0
    var averageSpeed: CLLocationSpeed = 0
    var maxSpeed: CLLocationSpeed = 0
    
    init() {
        self.startedAt = .now
    }
}
