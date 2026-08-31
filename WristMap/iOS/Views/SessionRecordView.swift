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
    var sessionManager: SessionManager
    @Binding var selectedDetents: PresentationDetent
    @Binding var isSessionActive: Bool
    
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
                if tracker.trackerStatus == .inactive && !sessionManager.isSessionRestored {
                    SessionActionButton(
                        title: "Start",
                        systemImage: "play",
                        tint: .blue,
                        action: {
                            tracker.startTracking()
                            sessionManager.createEmptySession(context: context)
                            isSessionActive = true
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
            if selectedDetents != SheetDetent.compact {
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
                .disabled(sessionManager.selectedSession == nil)
            }
        }
        .padding()
        .sheet(isPresented: $isShowingSaveSession) {
            if let session = sessionManager.selectedSession {
                SaveSessionView(
                    tracker: tracker,
                    isSessionActive: $isSessionActive,
                    activeSession: session,
                    onSessionDiscarded: {
                        sessionManager.selectedSession = nil
                    }
                )
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            if sessionManager.isSessionRestored {
                tracker.restoreTracking()
                sessionManager.isSessionRestored = false
                isSessionActive = true
            }
        }
        .bottomSheetStyle(selectedDetent: $selectedDetents)
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
