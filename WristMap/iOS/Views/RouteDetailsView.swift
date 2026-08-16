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
        let optimizedElevationPoints = optimizeElevationPoints(points: allPoints, targetCount: 200)
        return optimizedElevationPoints
    }
    private var maxElevation: Double { elevationPoints.map(\.elevation).max() ?? 0 }
    private var minElevation: Double { elevationPoints.map(\.elevation).min() ?? 0 }
    private var gainAndLoss: (gain: Double, loss: Double) {
        calculateGainAndLoss(points: elevationPoints)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // show chart only if sheet is expanded
                if selectedDetents != SheetDetent.compact {
                    elevationSummary
                }
                if selectedDetents == .large {
                    elevationChart
                }
                
                Spacer()
            }
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
    
    // optimize elevation points to max 200
    private func optimizeElevationPoints(
        points: [ElevationPoint],
        targetCount: Int
    ) -> [ElevationPoint] {
        guard points.count > targetCount,
              let first = points.first,
              let last = points.last
        else { return points }
        
        let totalDistance = last.distance
        let interval = totalDistance / Double(targetCount - 1)
        
        var result: [ElevationPoint] = [first]
        result = []
        
        var nextDistance = interval
        
        for point in points {
            if point.distance >= nextDistance {
                result.append(point)
                nextDistance += interval
            }
        }
        
        if result.last?.distance != last.distance {
            result.append(last)
        }
        
        return result
    }
    
    private var elevationSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                SessionDetailsTextView(
                    label: "Elevation Gain",
                    dataText: "\(DataFormatter.elevation(gainAndLoss.gain))"
                )
                SessionDetailsTextView(
                    label: "Elevation Loss",
                    dataText: "\(DataFormatter.elevation(gainAndLoss.loss))"
                )
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                SessionDetailsTextView(
                    label: "Max Elevation",
                    dataText: "\(DataFormatter.elevation(maxElevation))"
                )
                SessionDetailsTextView(
                    label: "Min Elevation",
                    dataText: "\(DataFormatter.elevation(minElevation))"
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var elevationChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elevation")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(elevationPoints) { point in
                LineMark(
                    x: .value("Distance", point.distance),
                    y: .value("Elevation", point.elevation)
                )
            }
            // limit x by start and end of route (so there is no padding inside the chart)
            .chartXScale(domain: elevationPoints.first!.distance...elevationPoints.last!.distance)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    
                    AxisValueLabel {
                        if let distance = value.as(Double.self) {
                            Text(DataFormatter.shortDistance(distance))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    
                    AxisValueLabel {
                        if let elevation = value.as(Double.self) {
                            Text(DataFormatter.shortDistance(elevation))
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding()
        }
    }
    
    // calculate gain and loss evelation
    private func calculateGainAndLoss(points: [ElevationPoint]) -> (gain: Double, loss: Double) {
        guard points.count > 1 else { return (0, 0) }
        
        let threshold: Double = 2.0
        
        var gain = 0.0
        var loss = 0.0
        var lastSignificantElevation = points[0].elevation
        
        for point in points.dropFirst() {
            let delta = point.elevation - lastSignificantElevation
            
            if abs(delta) >= threshold {
                if delta > 0 {
                    gain += delta
                } else {
                    loss += abs(delta)
                }
                
                lastSignificantElevation = point.elevation
            }
        }
        
        return (gain, loss)
    }
}

struct ElevationPoint: Identifiable {
    var id = UUID()
    var distance: Double // in meters
    var elevation: Double // in meters
}
