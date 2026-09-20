//
//  SessionDetailsView.swift
//  WristMap
//

import SwiftUI

struct SessionDetailsView_watchOS: View {
    @Environment(WatchConnectivityManager.self) private var watchConnectivityManager
    let session: Session
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // distance
                SessionDetailRow(
                    title: "Distance",
                    data: DataFormatter.distance(session.distance),
                )
                // duration
                SessionDetailRow(
                    title: "Duration",
                    data: DataFormatter.duration(session.duration)
                )
                .foregroundStyle(.yellow)
                // avg speed
                SessionDetailRow(
                    title: "Avg Speed",
                    data: DataFormatter.speed(session.averageSpeed)
                )
                // max speed
                SessionDetailRow(
                    title: "Max Speed",
                    data: DataFormatter.speed(session.maxSpeed)
                )
                // started at
                SessionDetailRow(
                    title: "Started at",
                    data: DataFormatter.date(session.startedAt)
                )
                // finished at
                if let finishedAt = session.finishedAt {
                    SessionDetailRow(
                        title: "Finished at",
                        data: DataFormatter.date(finishedAt)
                    )
                }
                syncStatusView
            }
        }
    }
    
    @ViewBuilder
    private var syncStatusView: some View {
        switch session.syncStatus {
        case .notApplicable:
            EmptyView()
        case .pending:
            statusRow(icon: "clock.circle.fill", color: .yellow, label: "Pending")
        case .synced:
            statusRow(icon: "checkmark.circle.fill", color: .green, label: "Synced")
        case .failed:
            VStack(alignment: .leading, spacing: 4) {
                statusRow(icon: "xmark.circle.fill", color: .red, label: "Failed to Sync")
                Button("Try Again", systemImage: "repeat") {
                    watchConnectivityManager.syncSession(session)
                }
            }
        }
    }
    
    private func statusRow(icon: String, color: Color, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
