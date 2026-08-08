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
}

