//
//  MoreMenuView.swift
//  WristMap Watch App
//

import SwiftUI
import SwiftData

struct MoreMenuView_watchOS: View {
    @Environment(\.modelContext) private var context
    
    @StateObject var tracker: LocationTracker
    var sessionManager: SessionManager 
    
    @State private var isShowingSaveSession: Bool = false
    
    @State private var verticalSelection = 0
    @State private var horizontalSelection = 0
    
    var sessions: [Session]
    
    var body: some View {
        NavigationStack {
            // horizontal pages
            TabView(selection: $horizontalSelection) {
                // vertical pages
                TabView(selection: $verticalSelection) {
                    // session info
                    SessionInfoView(tracker: tracker)
                        .navigationTitle("Info")
                        .tag(0)
                    
                    // session controls
                    SessionControlsView(
                        tracker: tracker,
                        sessionManager: sessionManager,
                        isShowingSaveSession: $isShowingSaveSession
                    )
                    .navigationTitle("Controls")
                    .tag(1)
                }
                .tabViewStyle(.verticalPage)
                .tag(0)
                // sessions list
                SessionsListView_watchOS(
                    sessionManager: sessionManager,
                    sessions: sessions
                )
                .navigationTitle("Library")
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .sheet(isPresented: $isShowingSaveSession) {
                if let session = sessionManager.selectedSession {
                    SaveSessionView(
                        tracker: tracker,
                        isSessionActive: Binding(
                            get: { sessionManager.isSessionActive },
                            set: { sessionManager.isSessionActive = $0 }
                        ),
                        activeSession: session,
                        onSessionDiscarded: {
                            sessionManager.selectedSession = nil
                        }
                    )
                }
            }
        }
    }
}

struct SessionInfoView: View {
    @ObservedObject var tracker: LocationTracker
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // speed
                SessionDetailRow(
                    title: "Speed",
                    data: DataFormatter.speed(tracker.speed),
                )
                // distance
                SessionDetailRow(
                    title: "Distance",
                    data: DataFormatter.distance(tracker.distance),
                )
                // duration
                SessionDetailRow(
                    title: "Duration",
                    data: DataFormatter.duration(tracker.duration),
                )
                .foregroundStyle(.yellow)
                // avg speed
                SessionDetailRow(
                    title: "Avg Speed",
                    data: DataFormatter.speed(tracker.averageSpeed),
                )
                // max speed
                SessionDetailRow(
                    title: "Max Speed",
                    data: DataFormatter.speed(tracker.maxSpeed)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct SessionControlsView: View {
    @Environment(\.modelContext) private var context
    
    @ObservedObject var tracker: LocationTracker
    var sessionManager: SessionManager
    @Binding var isShowingSaveSession: Bool
    
    var body: some View {
        VStack {
            if tracker.trackerStatus == .inactive && !sessionManager.isSessionRestored {
                Button("Start Session", systemImage: "play") {
                    tracker.startWorkoutTracking()
                    sessionManager.createEmptySession(context: context)
                    sessionManager.isSessionActive = true
                }
                .tint(.blue)
            }
            if tracker.trackerStatus == .active || tracker.trackerStatus == .paused {
                Button(
                    tracker.trackerStatus == .active ? "Pause" : "Continue",
                    systemImage: tracker.trackerStatus == .active ? "pause.circle" : "playpause"
                ) {
                    if tracker.trackerStatus == .active {
                        tracker.pauseTracking()
                    } else if tracker.trackerStatus == .paused {
                        tracker.resumeTracking()
                    }
                }
                .tint(.orange)
            }
            Button("Finish Session", systemImage: "stop") {
                tracker.pauseTracking()
                isShowingSaveSession = true
            }
            .disabled(sessionManager.selectedSession == nil)
        }
        .onAppear {
            if sessionManager.isSessionRestored {
                tracker.restoreTracking()
                sessionManager.isSessionRestored = false
                sessionManager.isSessionActive = true
            }
        }
    }
}

struct SessionsListView_watchOS: View {
    @Environment(\.modelContext) private var context
    var sessionManager: SessionManager
    var sessions: [Session]
    
    @State private var sessionToDelete: Session?
    @State private var isShowingSessionDeleteConfirm = false
    @State private var isShowingSessionDetails: Bool = false
    
    @State private var selectedSession: Session?
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                Button {
                    selectedSession = session
                } label: {
                    let formattedDistance = DataFormatter.distance(session.distance)
                    let formattedDuration = DataFormatter.shortDuration(
                        startedAt: session.startedAt,
                        finishedAt: session.finishedAt
                    )
                    
                    ItemRow(
                        title: session.name,
                        subtitle: "\(formattedDistance) • \(formattedDuration)",
                        systemImage: "figure.outdoor.cycle"
                    )
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash") {
                        sessionToDelete = session
                        isShowingSessionDeleteConfirm = true
                    }
                    .tint(.red)
                }
            }
        }
        .overlay {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label("No sessions yet", systemImage: "bicycle.circle")
                } description: {
                    Text("Finish session and it will appear here")
                }
            }
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailsView_watchOS(session: session)
        }
        .confirmationDialog(
            "Delete Session?",
            isPresented: $isShowingSessionDeleteConfirm,
        ) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    sessionManager.deleteSession(
                        context: context,
                        session: session
                    )
                }
                sessionToDelete = nil
            }
        } message: {
            Text("This action cannot be undone")
        }
    }
}

struct ItemRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
