//
//  SessionDetailsView.swift
//  WristMap
//

import SwiftUI
import MapKit

struct SessionDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedDetents: PresentationDetent
    var session: Session
    let isRouteRecenterActive: Bool
    let onClose: () -> Void
    let recenter: ([CLLocationCoordinate2D]) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if selectedDetents != SheetDetent.compact {
                        sessionOverview
                        timingSection
                    }
                    
                    if selectedDetents == .large {
                        sourceInformation
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
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
                }
            }
            .navigationTitle(session.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .bottomSheetStyle(
            detents: [
                SheetDetent.compact,
                SheetDetent.medium,
                SheetDetent.large
            ],
            selectedDetent: $selectedDetents
        )
    }
    
    private var sessionOverview: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            alignment: .leading,
            spacing: 20
        ) {
            metric("Distance", DataFormatter.distance(session.distance))
            metric("Duration", DataFormatter.duration(session.duration))
            metric("Avg Speed", DataFormatter.speed(session.averageSpeed))
            metric("Max Speed", DataFormatter.speed(session.maxSpeed))
        }
    }
    
    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timing")
                .font(.headline)
            
            detailRow("Started at", DataFormatter.date(session.startedAt))
            
            if let finishedAt = session.finishedAt {
                detailRow("Finished at", DataFormatter.date(finishedAt))
            }
        }
    }
    
    @ViewBuilder
    private var sourceInformation: some View {
        if true {
            HStack(spacing: 6) {
                Image(systemName: "applewatch")
                Text("Imported from Apple Watch")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func metric(
        _ label: String,
        _ value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func detailRow(
        _ label: String,
        _ value: String
    ) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}
