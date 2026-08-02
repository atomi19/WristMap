//
//  HomeViewModel.swift
//  WristMap
//

import Observation
import CoreLocation

@Observable
final class HomeViewModel {
    var selectedRoute: Route? = nil
    var points: [GPXPoint] = []
    // route distance markers (km)
    var routeDistanceMarkers: [RouteDistanceMarker] = []
    
    var selectedSession: Session? = nil
    var sessionPoints: [CLLocation] = []
    var isSessionRestored: Bool = false
    
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
    
    // restore unfinished session after reopening app
    func restoreActiveSession(from sessions: [Session]) -> Bool {
        guard let lastSession = sessions.first, lastSession.finishedAt == nil else {
            return false
        }
        
        sessionPoints = sortedCLLocations(from: lastSession.sessionPoints)
        selectedSession = lastSession
        isSessionRestored = true
        return true
    }
    
    func clearRoute() {
        selectedRoute = nil
        points = []
        routeDistanceMarkers = []
    }
    
    // select session
    func select(session: Session) {
        sessionPoints = sortedCLLocations(from: session.sessionPoints)
        selectedSession = session
    }
    
    func sortedCLLocations(from sessionPoints: [SessionPoint]) -> [CLLocation] {
        sessionPoints
            .sorted { $0.timestamp < $1.timestamp }
            .map { point in
                CLLocation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: point.latitude,
                        longitude: point.longitude
                    ),
                    altitude: point.elevation,
                    horizontalAccuracy: 0,
                    verticalAccuracy: 0,
                    course: 0,
                    speed: point.speed,
                    timestamp: point.timestamp
                )
            }
    }
}
