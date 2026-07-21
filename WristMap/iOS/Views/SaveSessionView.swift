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
    
    var activeSession: Session
    var locationHistory: [CLLocation]
    
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
                                tracker.locationHistory.removeAll()
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
                    }
                    .disabled(
                        sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        locationHistory.count <= 1
                    )
                }
            }
        }
    }
    
    private func saveSession(_ activeSession: Session) {
        do {
            let points = locationHistory.map {location in
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
            activeSession.finishedAt = .now
            activeSession.duration = tracker.duration
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
