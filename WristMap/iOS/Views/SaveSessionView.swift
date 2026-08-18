//
//  SaveSessionView.swift
//  WristMap
//

import SwiftUI
import SwiftData
import Foundation
import CoreLocation

struct SaveSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var tracker: LocationTracker
    
    @State private var isShowingSessionDiscard: Bool = false
    @State private var sessionName: String = ""
    
    @Binding var isSessionActive: Bool
    var activeSession: Session
    let onSessionDiscarded: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Session Name", text: $sessionName)
            }
            .navigationTitle("Save Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        isShowingSessionDiscard = true
                    }
                    .confirmationDialog(
                        "Are you sure you want to discard session?",
                        isPresented: $isShowingSessionDiscard,
                    ) {
                        Button("Continue Session") {
                            tracker.resumeTracking()
                            dismiss()
                        }
                        .tint(.blue)
                        Button("Discard Session", role: .destructive) {
                            context.delete(activeSession)
                            
                            do {
                                try context.save()
                                tracker.stopTracking()
                                tracker.resetTracker()
                                onSessionDiscarded()
                                isSessionActive = false
                                dismiss()
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm", systemImage: "checkmark") {
                        saveSession(activeSession)
                        tracker.resetTracker()
                        onSessionDiscarded()
                        isSessionActive = false
                    }
                    .disabled(
                        sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        tracker.locationHistory.count <= 1
                    )
                }
            }
        }
        .task {
            guard sessionName.isEmpty else { return }
            
            // suggest session name
            if let suggestedName = await suggestSessionName() {
                sessionName = suggestedName
            }
        }
    }
    
    // suggest session name based on location of start and end points
    private func suggestSessionName() async -> String? {
        let startGeodecoder = CLGeocoder()
        let endGeodecoder = CLGeocoder()
        
        guard let startPoint = tracker.locationHistory.first,
              let endPoint = tracker.locationHistory.last else { return nil }
        
        async let start = startGeodecoder.reverseGeocodeLocation(startPoint)
        async let end = endGeodecoder.reverseGeocodeLocation(endPoint)
        
        guard let startCity = try? await start.first?.locality,
              let endCity = try? await end.first?.locality else { return nil }
        
        if startCity == endCity {
            return startCity
        } else {
            return "\(startCity) → \(endCity)"
        }
    }
    
    private func saveSession(_ activeSession: Session) {
        do {
            let points = tracker.locationHistory.map {location in
                SessionPoint(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    elevation: location.altitude,
                    speed: location.speed,
                    timestamp: location.timestamp
                )
            }

            activeSession.name = sessionName
            activeSession.sessionPoints = points
            activeSession.distance = tracker.distance
            
            let finishedAt = Date()
            activeSession.finishedAt = finishedAt
            activeSession.duration = finishedAt.timeIntervalSince(activeSession.startedAt)
            
            activeSession.movingDuration = 0
            activeSession.averageSpeed = tracker.averageSpeed
            activeSession.maxSpeed = tracker.maxSpeed
            
            try context.save()
            
            tracker.stopTracking()
            
            dismiss()
        } catch {
            print(error)
        }  
    }
}
