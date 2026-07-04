//
//  CustomUserLocationButton.swift
//  WristMap
//

import SwiftUI
import MapKit

struct CustomUserLocationButton: View {
    @Binding var position: MapCameraPosition
    @Binding var userTrackingMode: UserTrackingModes
    
    var body: some View {
        Button {
            switch userTrackingMode {
            case .none:
                userTrackingMode = .follow
            case .follow:
                userTrackingMode = .followWithHeading
            case .followWithHeading:
                userTrackingMode = .none
            }
            
            position = userTrackingMode.cameraPosition
        } label: {
            switch userTrackingMode {
            case .none:
                Image(systemName: "location")
            case .follow:
                Image(systemName: "location.fill")
            case .followWithHeading:
                Image(systemName: "location.north.line.fill")
            }
        }
    }
}

enum UserTrackingModes {
    case none
    case follow
    case followWithHeading
    
    var cameraPosition: MapCameraPosition {
        switch self {
        case .none:
            .automatic
        case .follow:
            .userLocation(
                followsHeading: false,
                fallback: .automatic
            )
        case .followWithHeading:
            .userLocation(
                followsHeading: true,
                fallback: .automatic
            )
        }
    }
}
