//
//  MapRecenter.swift
//  WristMap
//
import CoreLocation
import Foundation
import MapKit
import SwiftUI

enum MapRecenter {
    static func recenter(
        coordinates: [CLLocationCoordinate2D],
        position: Binding<MapCameraPosition>,
        trackingMode: Binding<UserTrackingModes>,
        isRouteRecenterActive: Binding<Bool>
    ) {
        var rect = MKMapRect.null
        trackingMode.wrappedValue = .none
        
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
            position.wrappedValue = .rect(paddingRect)
        }
        
        isRouteRecenterActive.wrappedValue = true
    }
}
