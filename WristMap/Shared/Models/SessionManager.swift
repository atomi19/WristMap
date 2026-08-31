//
//  SessionManager.swift
//  WristMap
//

import Foundation
import CoreLocation
import SwiftData

@Observable
final class SessionManager {
    var selectedSession: Session? = nil
    var sessionPoints: [CLLocation] = []
    var isSessionRestored = false
    var isSessionActive = false
    
    func restoreActiveSession(from sessions: [Session]) -> Bool {
        guard let lastSession = sessions.first, lastSession.finishedAt == nil else {
            return false
        }
        
        sessionPoints = sortedCLLocations(from: lastSession.sessionPoints)
        selectedSession = lastSession
        isSessionRestored = true
        return true
    }
    
    func select(session: Session) {
        sessionPoints = sortedCLLocations(from: session.sessionPoints)
        selectedSession = session
    }
    
    func clear() {
        selectedSession = nil
        sessionPoints.removeAll()
        isSessionRestored = false
        isSessionActive = false
    }
    
    func recordNewPoints(newLocations: [CLLocation], context: ModelContext) {
        guard let activeSession = selectedSession, !newLocations.isEmpty else { return }
        
        let newPoints = newLocations.map { point in
            SessionPoint(
                latitude: point.coordinate.latitude,
                longitude: point.coordinate.longitude,
                elevation: point.altitude,
                speed: point.speed,
                timestamp: point.timestamp,
            )
        }
        
        activeSession.sessionPoints.append(contentsOf: newPoints)
        
        do {
            try context.save()
        } catch {
            print("Failed to save new locations: \(error)")
        }
    }
    
    func createEmptySession(context: ModelContext) {
        let session = Session()
        context.insert(session)
        
        do {
            try context.save()
        } catch {
            print("Failed to create session: \(error)")
            context.delete(session)
        }
        
        selectedSession = session
    }
    
    func deleteSession(context: ModelContext, session: Session) {
        context.delete(session)
        
        do {
            try context.save()
        } catch {
            print("Error deleting session: \(error)")
        }
    }
    
    private func sortedCLLocations(from sessionPoints: [SessionPoint]) -> [CLLocation] {
        sessionPoints
            .sorted { $0.timestamp < $1.timestamp }
            .map { point in
                CLLocation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: point.latitude,
                        longitude: point.longitude
                    ),
                    altitude: point.elevation,
                    horizontalAccuracy: 0,
                    verticalAccuracy: 0,
                    course: 0,
                    speed: point.speed,
                    timestamp: point.timestamp
                )
            }
    }
}
