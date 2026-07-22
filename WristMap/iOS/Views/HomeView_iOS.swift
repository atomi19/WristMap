//
//  ContentView.swift
//  WristMap
//

import SwiftUI
import MapKit
internal import UniformTypeIdentifiers
import CoreLocation
import Foundation
import SwiftData

enum ActiveSheet: Identifiable {
    var id: Self { self }
    
    case routesLibrary
    case routeDetails
    case sessionRecord
    case sessionDetails
}

struct SheetDetent {
    var routeDetails: PresentationDetent = .height(75)
    var sessionRecord: PresentationDetent = .height(75)
    var sessionDetails: PresentationDetent = .height(75)
}

struct HomeView_iOS: View {
    @StateObject private var tracker = LocationTracker()
    
    @State private var selectedRoute: Route? = nil
    @State private var points: [GPXPoint] = []
    
    @State private var selectedSession: Session? = nil
    @State private var sessionPoints: [CLLocation] = []
    @State private var isSessionRestored: Bool = false
    
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: UserTrackingModes = .follow
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    @State private var isRouteRecenterActive: Bool = false
    
    @State private var activeSheet: ActiveSheet?
    @State private var sheetDetent = SheetDetent()
    
    @Query(sort: \Session.startedAt, order: .reverse)
    private var sessions: [Session]
    
    // settings
    @State private var selectedMapStyle: SelectedMapStyle = Settings.mapStyle
    
    // route distance markers (km)
    @State private var routeDistanceMarkers: [RouteDistanceMarker] = []

    var body: some View {
        NavigationStack {
            HomeMapView(
                tracker: tracker,
                position: $position,
                points: points,
                sessionPoints: sessionPoints,
                trackingPoints: tracker.locationHistory,
                routeDistanceMarkers: routeDistanceMarkers
            )
            .task(id: selectedRoute?.uuid) {
                guard let route = selectedRoute else {
                    points = []
                    return
                }
                
                do {
                    let url = GPXFileManager.fileURL(for: route.uuid)
                    points = try GPXParser().parse(url: url)
                    calculateDistanceMarkers(route: route)
                    activeSheet = .routeDetails
                } catch {
                    points = []
                    print(error)
                }
            }
            .task(id: selectedSession?.uuid) {
                guard let session = selectedSession else {
                    sessionPoints = []
                    return
                }
                
                let sortedSession = session.sessionPoints.sorted { $0.timestamp < $1.timestamp }
                
                sessionPoints = sortedSession.map { point in
                    CLLocation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: point.latitude,
                            longitude: point.longitude
                        ),
                        altitude: point.elevation,
                        horizontalAccuracy: 0,
                        verticalAccuracy: 0,
                        timestamp: point.timestamp
                    )
                }
            }
            .mapControls {
                MapScaleView()
            }
            .mapStyle(selectedMapStyle.mapStyle)
            .onChange(of: selectedMapStyle) {
                Settings.mapStyle = selectedMapStyle
            }
            .onChange(of: position) { _ , newValue in
                if newValue.positionedByUser {
                    isRouteRecenterActive = false
                    trackingMode = .none
                }
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                
                if let lastSession = sessions.first {
                    if lastSession.finishedAt == nil {
                        let sortedSession = lastSession.sessionPoints.sorted {$0.timestamp < $1.timestamp}
                        sessionPoints = sortedSession.map { point in
                            CLLocation(
                                coordinate: CLLocationCoordinate2D(
                                    latitude: point.latitude,
                                    longitude: point.longitude
                                ),
                                altitude: point.elevation,
                                horizontalAccuracy: 0,
                                verticalAccuracy: 0,
                                timestamp: point.timestamp
                            )
                        }
                        tracker.locationHistory = sessionPoints
                        
                        selectedSession = lastSession
                        activeSheet = .sessionRecord
                        isSessionRestored = true
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    CustomUserLocationButton(
                        position: $position,
                        userTrackingMode: $trackingMode
                    )
                    Menu {
                        ControlGroup {
                            ForEach(SelectedMapStyle.allCases) { style in
                                Button {
                                    selectedMapStyle = style
                                } label: {
                                    Label(
                                        style.rawValue,
                                        systemImage: style.systemImage
                                    )
                                }
                            }
                        }
                        Divider()
                        Button("Routes", systemImage: "map") {
                            activeSheet = .routesLibrary
                        }
                        Button("Session", systemImage: "location.viewfinder") {
                            activeSheet = .sessionRecord
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                sheetView(sheet: sheet)
            }
        }
    }
    
    @ViewBuilder
    private func sheetView(sheet: ActiveSheet) -> some View {
        switch sheet {
        case .routesLibrary:
            RoutesLibraryView(
                sessions: sessions,
                onRouteTap: { route in
                    self.selectedRoute = route
                    activeSheet = nil
                },
                onSessionTap: { session in
                    selectedSession = session
                    activeSheet = .sessionDetails
                }
            )
        case .routeDetails:
            if let route = selectedRoute {
                RouteDetailsView(
                    route: route,
                    isRouteRecenterActive: $isRouteRecenterActive,
                    selectedDetents: sheetDetent.routeDetails,
                    points: points,
                    onClose: {
                        selectedRoute = nil
                        activeSheet = nil
                        points = []
                    },
                    recenter: recenter,
                )
                .bottomSheetStyle(selectedDetent: $sheetDetent.routeDetails)
            }
        case .sessionRecord:
            SessionRecordView(
                tracker: tracker,
                selectedDetents: $sheetDetent.sessionRecord,
                activeSession: $selectedSession,
                isSessionRestored: $isSessionRestored,
            )
            .bottomSheetStyle(selectedDetent: $sheetDetent.sessionRecord)
        case .sessionDetails:
            if let session = selectedSession {
                SessionDetailsView(
                    session: session,
                    selectedDetents: sheetDetent.sessionDetails,
                    isRouteRecenterActive: isRouteRecenterActive,
                    onClose: {
                        activeSheet = nil
                        sessionPoints.removeAll()
                    },
                    recenter: recenter,
                )
                .bottomSheetStyle(selectedDetent: $sheetDetent.sessionDetails)
            }
        }
    }
    
    private func recenter(coordinates: [CLLocationCoordinate2D]) {
        var rect = MKMapRect.null
        trackingMode = .none
        
        for coordinate in coordinates {
            rect = rect.union(
                MKMapRect(
                    origin: MKMapPoint(coordinate),
                    size: MKMapSize(width: 1, height: 1)
                )
            )
        }
        
        // add padding from the screen edges when recenter on route
        let paddingRect = rect.insetBy(
            dx: -rect.size.width * 0.2,
            dy: -rect.size.height * 0.2
        )
        
        withAnimation(.easeInOut) {
            position = .rect(paddingRect)
        }
        
        isRouteRecenterActive = true
    }
    
    // calculate coordinates for distance markers on route
    private func calculateDistanceMarkers(route: Route) {
        let totalDistance = route.distance / 1000
        
        let targetMarkers = 10.0
        let rawInterval = totalDistance / targetMarkers
        
        let niceIntervals: [Double] = [
            1, 2, 5, 10, 20, 25, 50, 100
        ]
        
        let interval = niceIntervals.first(where: { $0 >= rawInterval }) ?? 100
        
        // count from interval by interval to total route distance
        let markerDistances = Array(
            stride(
                from: interval,
                to: totalDistance,
                by: interval
            )
        )
        
        var markerIndex = 0
        var distance: Double = 0
        routeDistanceMarkers.removeAll()
        
        // go through GPX points
        // and add distance marker if a target distance is reached
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
                    distance >= markerDistances[markerIndex] * 1000 {
                routeDistanceMarkers.append(
                    RouteDistanceMarker(
                        distance: markerDistances[markerIndex],
                        coordinate: points[i].coordinate
                    )
                )
                
                markerIndex += 1
            }
        }
    }
}

private struct BottomSheetView: ViewModifier {
    @Binding var selectedDetent: PresentationDetent
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(
                [
                    .height(75),
                    .height(250)
                ],
                selection: $selectedDetent
            )
            .presentationBackgroundInteraction(.enabled(upThrough: .height(250)))
            .interactiveDismissDisabled()
    }
}

extension View {
    func bottomSheetStyle(
        selectedDetent: Binding<PresentationDetent>
    ) -> some View {
        self.modifier(BottomSheetView(selectedDetent: selectedDetent))
    }
}


#Preview {
    HomeView_iOS()
}
