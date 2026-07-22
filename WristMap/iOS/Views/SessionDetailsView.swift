//
//  SessionDetailsView.swift
//  WristMap
//

import SwiftUI
import MapKit

struct SessionDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    var session: Session
    let selectedDetents: PresentationDetent
    let isRouteRecenterActive: Bool
    let onClose: () -> Void
    let recenter: ([CLLocationCoordinate2D]) -> Void
    
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        onClose()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recenter(
                            session.sessionPoints.map {
                                CLLocationCoordinate2D(
                                    latitude: $0.latitude,
                                    longitude: $0.longitude
                                )
                            }
                        )
                    } label: {
                        Image(systemName: isRouteRecenterActive ? "map.fill" : "map")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(session.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
