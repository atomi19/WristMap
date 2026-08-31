//
//  SessionDetailsView.swift
//  WristMap
//

import SwiftUI

struct SessionDetailsView_watchOS: View {
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
            }
        }
    }
}
