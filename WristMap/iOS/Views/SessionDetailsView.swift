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
    
    private var maxElevation: Double { session.sessionPoints.map(\.elevation).max() ?? 0 }
    private var minElevation: Double { session.sessionPoints.map(\.elevation).min() ?? 0 }
    private var gainAndLoss: (gain: Double, loss: Double) {
        ElevationCalculator.calculateGainAndLoss(points: elevationPoints)
    }
    
    var elevationPoints: [ElevationPoint] {
        let sortedPoints = session.sessionPoints.sorted { $0.timestamp < $1.timestamp }
        guard sortedPoints.count > 1 else { return [] }
        
        var allPoints: [ElevationPoint] = []
        var distance = 0.0
        
        for i in sortedPoints.indices {
            let point = sortedPoints[i]
            
            if i > 0 {
                let previous = sortedPoints[i-1]
                
                let previousLocation = CLLocation(
                    latitude: previous.latitude,
                    longitude: previous.longitude
                )

                let currentLocation = CLLocation(
                    latitude: point.latitude,
                    longitude: point.longitude
                )

                // calculate distance for this point
                distance += previousLocation.distance(from: currentLocation)
            }
            
            allPoints.append(
                ElevationPoint(
                    distance: distance, // distance in meters
                    elevation: point.elevation
                )
            )
        }
        
        // optimize max 200 elevation points
        let optimizedElevationPoints = ElevationCalculator.optimizeElevationPoints(
            points: allPoints,
            targetCount: 200
        )
        
        return optimizedElevationPoints
    }
    
    private var averageMovingSpeed: Double {
        session.movingDuration > 0 ? session.distance / session.movingDuration : 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if selectedDetents != SheetDetent.compact {
                        sessionOverview
                        timingSection
                    }
                    
                    if selectedDetents == .large {
                        elevationSummary
                        elevationChartSection
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
            metric("Max Speed", DataFormatter.speed(session.maxSpeed))
            
            metric("Duration", DataFormatter.duration(session.duration))
            metric("Moving Duration", DataFormatter.duration(session.movingDuration))
            
            metric("Avg Speed", DataFormatter.speed(session.averageSpeed))
            metric("Avg Moving Speed", DataFormatter.speed(averageMovingSpeed))
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
    
    private var elevationSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevation")
                .font(.headline)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                alignment: .leading,
                spacing: 20
            ) {
                metric(
                    "Elevation Gain",
                    DataFormatter.elevation(gainAndLoss.gain)
                )
                metric(
                    "Elevation Loss",
                    DataFormatter.elevation(gainAndLoss.loss)
                )
                metric(
                    "Max Elevation",
                    DataFormatter.elevation(maxElevation)
                )
                metric(
                    "Min Elevation",
                    DataFormatter.elevation(minElevation)
                )
            }
        }
    }
    
    private var elevationChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevation Profile")
                .font(.headline)

            ElevationChart(elevationPoints: elevationPoints)
        }
    }
    
    @ViewBuilder
    private var sourceInformation: some View {
        if session.recordedOn == .appleWatch {
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
