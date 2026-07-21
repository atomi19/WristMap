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
    let selectedDetents: PresentationDetent
    let points: [GPXPoint]
    
    let onClose: () -> Void
    let onRouteRecenter: () -> Void
    let onTrackingSelected: () -> Void
    
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
                    distance: distance / 1000,
                    elevation: elevation
                )
            )
        }
        
        // optimize max 200 elevation points
        let optimizedElevationPoints = optimizeElevationPoints(points: allPoints, targetCount: 200)
        return optimizedElevationPoints
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // show chart only if sheet is expanded
                if selectedDetents != .height(75) {
                    Chart(elevationPoints) { point in
                        LineMark(
                            x: .value("Distance", point.distance),
                            y: .value("Elevation", point.elevation)
                        )
                    }
                    // limit x by start and end of route (so there is no padding inside the chart)
                    .chartXScale(domain: elevationPoints.first!.distance...elevationPoints.last!.distance)
                    .frame(height: 150)
                    .padding()
                }
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
                    Button(action: onRouteRecenter) {
                        Image(systemName: isRouteRecenterActive ? "map.fill" : "map")
                    }
                }
            }
        }
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
}

struct ElevationPoint: Identifiable {
    var id = UUID()
    var distance: Double // in km
    var elevation: Double // in meters
}
