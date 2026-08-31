//
//  HomeViewModel.swift
//  WristMap
//

import Observation
import CoreLocation

// ios only
@Observable
final class HomeViewModel {
    var selectedRoute: Route? = nil
    var points: [GPXPoint] = []
    // route distance markers in meters
    var routeDistanceMarkers: [RouteDistanceMarker] = []
        
    // load GPX route and parse it to points
    func loadRoute(_ route: Route) throws {
        let url = GPXFileManager.fileURL(for: route.uuid)
        let parsedPoints = try GPXParser().parse(url: url)
        
        points = parsedPoints
        routeDistanceMarkers = RouteDistanceMarkerCalculator.calculate(
            route: route,
            points: parsedPoints
        )
    }
    
    func clearRoute() {
        selectedRoute = nil
        points = []
        routeDistanceMarkers = []
    }
}
