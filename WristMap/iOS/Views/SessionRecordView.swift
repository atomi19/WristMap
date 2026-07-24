//
//  SessionRecordView.swift
//  WristMap
//

import SwiftUI
import CoreLocation
import SwiftData

struct SessionRecordView: View {
    @Environment(\.modelContext) private var context
    
    @ObservedObject var tracker: LocationTracker
    var selectedDetents: PresentationDetent
    @Binding var activeSession: Session?
    @Binding var isSessionRestored: Bool
    
    @State private var isShowingSaveSession: Bool = false
        
    var body: some View {
        VStack {
            // header
            HStack {
                // current speed
                VStack {
                    Text(DataFormatter.speed(tracker.speed))
                        .font(.headline)
                    Text("Speed")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // start tracking
                if tracker.trackerStatus == .inactive && !isSessionRestored {
                    SessionActionButton(
                        title: "Start",
                        systemImage: "play",
                        tint: .blue,
                        action: {
                            tracker.startTracking()
                            createSession()
                        }
                    )
                }
                // continue session
                if isSessionRestored {
                    SessionActionButton(
                        title: "Continue",
                        systemImage: "arrowtriangle.right.circle.fill",
                        tint: .blue,
                        action: {
                            tracker.restoreTracking()
                            isSessionRestored = false
                        }
                    )
                }
                // pause tracking
                if tracker.trackerStatus == .active || tracker.trackerStatus == .paused {
                    SessionActionButton(
                        title: tracker.trackerStatus == .active ? "Pause" : "Continue",
                        systemImage: tracker.trackerStatus == .active ? "pause.circle" : "playpause",
                        tint: .orange,
                        action: {
                            if tracker.trackerStatus == .active {
                                tracker.pauseTracking()
                            } else if tracker.trackerStatus == .paused {
                                tracker.resumeTracking()
                            }
                        }
                    )
                }
            }
            // body
            if selectedDetents != .height(75) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        SessionDetailsTextView(
                            label: "Distance",
                            dataText: DataFormatter.distance(tracker.distance)
                        )
                        SessionDetailsTextView(
                            label: "Duration",
                            dataText: DataFormatter.duration(tracker.duration)
                        )
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 16) {
                        SessionDetailsTextView(
                            label: "Avg Speed",
                            dataText: DataFormatter.speed(tracker.averageSpeed)
                        )
                        SessionDetailsTextView(
                            label: "Max Speed",
                            dataText: DataFormatter.speed(tracker.maxSpeed)
                        )
                    }
                }
                Spacer()
                // stop tracking
                Button(role: .destructive) {
                    tracker.pauseTracking()
                    isShowingSaveSession = true
                } label: {
                    Label("Finish", systemImage: "stop")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.large)
            }
        }
        .padding()
        .sheet(isPresented: $isShowingSaveSession) {
            if let session = activeSession {
                SaveSessionView(
                    tracker: tracker,
                    activeSession: session,
                    locationHistory: tracker.locationHistory,
                )
                .presentationDetents([.medium])
            }
        }
        .onChange(of: tracker.locationHistory) {
            if let activeSession {
                let points: [SessionPoint] = tracker.locationHistory.map { point in
                    SessionPoint(
                        latitude: point.coordinate.latitude,
                        longitude: point.coordinate.longitude,
                        elevation: point.altitude,
                        speed: point.speed,
                        timestamp: point.timestamp,
                    )
                }
                activeSession.sessionPoints = points
            }
        }
    }
    
    // create empty session 
    private func createSession() {
        do {
            let session = Session()
            activeSession = session
            
            context.insert(session)
            try context.save()
        } catch {
            print(error)
        }
    }
}

struct SessionActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
        .controlSize(.large)
    }
}
