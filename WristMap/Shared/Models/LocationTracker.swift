//
//  LocationTracker.swift
//  WristMap
//

import Foundation
import CoreLocation
internal import Combine

enum LocationTrackerStatus {
    case inactive
    case paused
    case active
}

class LocationTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var locationHistory: [CLLocation] = []
    @Published var trackerStatus: LocationTrackerStatus = .inactive
    @Published var speed: CLLocationSpeed = 0
    @Published var distance: CLLocationDistance = 0
    @Published var duration: TimeInterval = 0
    @Published var averageSpeed: CLLocationSpeed = 0
    @Published var maxSpeed: CLLocationSpeed = 0
    
    private var lastLocation: CLLocation?
    private var timer: Timer?
    private var lastLocationUpdate: Date?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 
        locationManager.allowsBackgroundLocationUpdates = true
        #if os(iOS)
        locationManager.pausesLocationUpdatesAutomatically = false
        #endif
    }
    
    func startTracking() {
        locationHistory.removeAll()
        lastLocation = nil
        lastLocationUpdate = nil
        speed = 0
        distance = 0
        duration = 0
        averageSpeed = 0
        maxSpeed = 0
        
        locationManager.startUpdatingLocation()
        trackerStatus = .active
        locationManager.requestWhenInUseAuthorization()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.locationHistory.first?.timestamp else {return}
            
            // set speed to 0 if last location update is > 5 sec
            if let lastLocationUpdate, Date().timeIntervalSince(lastLocationUpdate) > 5 {
                speed = 0
            }
            
            duration = Date().timeIntervalSince(start)
        }
    }
    
    func pauseTracking() {
        locationManager.stopUpdatingLocation()
        trackerStatus = .paused
    }
    
    func resumeTracking() {
        locationManager.startUpdatingLocation()
        trackerStatus = .active
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        trackerStatus = .inactive
        
        timer?.invalidate()
        timer = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard trackerStatus == .active else {return}
        
        guard let location = locations.last else {return}
        
        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy < 20 else { return }

        lastLocationUpdate = location.timestamp
        
        if let lastLocation {
            distance += location.distance(from: lastLocation)
        }
        
        // movement coordinates
        lastLocation = location
        locationHistory.append(location)
        
        speed = max(location.speed, 0)
        averageSpeed = duration > 0 ? distance / duration : 0
        maxSpeed = max(maxSpeed, location.speed)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location \(error.localizedDescription)")
    }
}
