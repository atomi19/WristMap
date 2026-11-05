//
//  RouteDistanceMarkerCalculator.swift
//  WristMap
//

import CoreLocation

enum RouteDistanceMarkerCalculator {
    static func calculate(route: Route, points: [GPXPoint]) -> [RouteDistanceMarker] {
        guard points.count > 1 else { return [] }
        
        let totalDistance = route.distance // distance in meters
        
        let targetMarkers = 10.0
        let rawInterval = totalDistance / targetMarkers
        
        let niceIntervalsInMeters: [Double] = Settings.measurementSystem.usesMetric
        ? [
            100,
            200,
            500,
            1000,
            2000,
            5000,
            10000,
            20000
        ]
        : [
            160.9344, // 0.1 mile
            321.8688, // 0.2
            804.672, // 0.5
            1609.344, // 1
            3218.688, // 2
            8046.72, // 5
            16093.44, // 10
            32186.88 // 20
        ]
        
        let interval = niceIntervalsInMeters.first(where: { $0 >= rawInterval }) ?? niceIntervalsInMeters.last!
        
        // count from interval by interval to total route distance
        let markerDistances = Array(
            stride(
                from: interval,
                to: totalDistance,
                by: interval
            )
        )
        
        var markers: [RouteDistanceMarker] = []
        var markerIndex = 0
        var distance: Double = 0
        
        for i in 1..<points.count {
            let start = CLLocation(
                latitude: points[i - 1].coordinate.latitude,
                longitude: points[i - 1].coordinate.longitude
            )
            
            let end = CLLocation(
                latitude: points[i].coordinate.latitude,
                longitude: points[i].coordinate.longitude
            )
            
            distance += start.distance(from: end)
            
            while markerIndex < markerDistances.count &&
                    distance >= markerDistances[markerIndex] {
                markers.append(
                    RouteDistanceMarker(
                        distance: markerDistances[markerIndex], // in meters
                        coordinate: points[i].coordinate
                    )
                )
                
                markerIndex += 1
            }
        }
        
        return markers
    }
    
    static func calculateDistance(points: [GPXPoint]) -> Double {
        guard points.count > 1 else { return 0 }
        
        var total: Double = 0
        
        for i in 1..<points.count {
            let start = CLLocation(
                latitude: points[i - 1].coordinate.latitude,
                longitude: points[i - 1].coordinate.longitude
            )
            
            let end = CLLocation(
                latitude: points[i].coordinate.latitude,
                longitude: points[i].coordinate.longitude
            )
            
            total += start.distance(from: end)
        }
        return total
    }
    
    static func calculateGainAndLoss(points: [ElevationPoint]) -> (gain: Double, loss: Double) {
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
    
    // optimize elevation points to max 200
    static func optimizeElevationPoints(points: [ElevationPoint], targetCount: Int) -> [ElevationPoint] {
        guard points.count > targetCount,
                let last = points.last
        else { return points }
        
        let totalDistance = last.distance
        let interval = totalDistance / Double(targetCount - 1)
        
        var result: [ElevationPoint] = []
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

