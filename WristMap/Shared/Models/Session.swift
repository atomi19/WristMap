//
//  Tracking.swift
//  WristMap
//

import Foundation
import SwiftData
import CoreLocation

enum RecordingSource: String, Codable {
    case iPhone
    case appleWatch
}

enum SyncStatus: String, Codable {
    case notApplicable
    case pending
    case synced
    case failed
}

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
    
    // prefill for ios
    var recordedOn: RecordingSource = RecordingSource.iPhone
    var syncStatus: SyncStatus = SyncStatus.notApplicable
    
    init() {
        self.startedAt = .now
        self.recordedOn = RecordingSource.iPhone
        self.syncStatus = SyncStatus.notApplicable
    }
}
