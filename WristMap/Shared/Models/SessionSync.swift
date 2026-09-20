//
//  SessionSync.swift
//  WristMap
//

import Foundation

struct SessionSyncPayload: Codable {
    let uuid: UUID
    let name: String
    let distance: Double
    let startedAt: Date
    let finishedAt: Date?
    let duration: TimeInterval
    let movingDuration: TimeInterval
    let averageSpeed: Double
    let maxSpeed: Double
    let points: [SessionPointSyncPayload]

    init(_ session: Session) {
        uuid = session.uuid
        name = session.name
        distance = session.distance
        startedAt = session.startedAt
        finishedAt = session.finishedAt
        duration = session.duration
        movingDuration = session.movingDuration
        averageSpeed = session.averageSpeed
        maxSpeed = session.maxSpeed
        points = session.sessionPoints.map {
            SessionPointSyncPayload(latitude: $0.latitude, longitude: $0.longitude, elevation: $0.elevation, speed: $0.speed, timestamp: $0.timestamp)
        }
    }
}

struct SessionPointSyncPayload: Codable {
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let speed: Double
    let timestamp: Date
}
