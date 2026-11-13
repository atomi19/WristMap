//
//  ElevationCalculator.swift
//  WristMap
//

import CoreLocation

enum ElevationCalculator {
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
