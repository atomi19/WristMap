//
//  SessionDetailsView.swift
//  WristMap
//

import SwiftUI

struct SessionDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    var session: Session
    let selectedDetents: PresentationDetent
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if selectedDetents != .height(75) {
                    HStack {
                        VStack(alignment: .leading) {
                            SessionDetailsTextView(
                                label: "Distance",
                                dataText: DataFormatter.distance(session.distance)
                            )
                            SessionDetailsTextView(
                                label: "Average Speed",
                                dataText: DataFormatter.speed(session.averageSpeed)
                            )
                            SessionDetailsTextView(
                                label: "Max Speed",
                                dataText: DataFormatter.speed(session.maxSpeed)
                            )
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            SessionDetailsTextView(
                                label: "Duration",
                                dataText: DataFormatter.duration(session.duration)
                            )
                            SessionDetailsTextView(
                                label: "Started at",
                                dataText: DataFormatter.date(session.startedAt)
                            )
                            if let finishedDate = session.finishedAt {
                                SessionDetailsTextView(
                                    label: "Finished at",
                                    dataText: DataFormatter.date(finishedDate)
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        onClose()
                    }
                }
            }
            .navigationTitle(session.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
