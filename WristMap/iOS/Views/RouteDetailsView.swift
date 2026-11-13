//
//  RouteDetailsView.swift
//  WristMap
//

import SwiftUI
import Charts
import CoreLocation

struct RouteDetailsView: View {
    let route: Route
    @Binding var isRouteRecenterActive: Bool
    @Binding var selectedDetents: PresentationDetent
    let points: [GPXPoint]
    let onClose: () -> Void
    let recenter: ([CLLocationCoordinate2D]) -> Void
    
    var elevationPoints: [ElevationPoint] {
        guard points.count > 1 else { return [] }
        
        var allPoints: [ElevationPoint] = []
        var distance = 0.0
        
        for i in points.indices {
            guard let elevation = points[i].elevation else { continue }
            
            if i > 0 {
                let previous = CLLocation(
                    latitude: points[i - 1].coordinate.latitude,
                    longitude: points[i - 1].coordinate.longitude
                )

                let current = CLLocation(
                    latitude: points[i].coordinate.latitude,
                    longitude: points[i].coordinate.longitude
                )

                // calculate distance for this point
                distance += previous.distance(from: current)
            }
            
            allPoints.append(
                ElevationPoint(
                    distance: distance, // distance in meters
                    elevation: elevation
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
    
    private var maxElevation: Double { elevationPoints.map(\.elevation).max() ?? 0 }
    private var minElevation: Double { elevationPoints.map(\.elevation).min() ?? 0 }
    private var gainAndLoss: (gain: Double, loss: Double) {
        ElevationCalculator.calculateGainAndLoss(points: elevationPoints)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if selectedDetents != SheetDetent.compact {
                        routeOverview
                        elevationSummary
                    }
                    
                    if selectedDetents == .large {
                        elevationChartSection
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(route.routeName)
                            .font(.title3)
                        Text(DataFormatter.distance(route.distance))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recenter(points.map(\.coordinate))
                    } label: {
                        Image(systemName: isRouteRecenterActive ? "map.fill" : "map")
                    }
                }
            }
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
    
    private var routeOverview: some View {
        metric(
            "Distance",
            DataFormatter.distance(route.distance)
        )
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
}
