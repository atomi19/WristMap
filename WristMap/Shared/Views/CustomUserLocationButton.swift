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
            
            withAnimation(.easeInOut) {
                position = userTrackingMode.cameraPosition
            }
        } label: {
            switch userTrackingMode {
            case .none:
                Image(systemName: "location")
                    .frame(width: 32, height: 32)
            case .follow:
                Image(systemName: "location.fill")
                    .frame(width: 32, height: 32)
            case .followWithHeading:
                Image(systemName: "location.north.line.fill")
                    .frame(width: 32, height: 32)
            }
        }
        #if os(iOS)
        .modifier(CustomUserLocationButtonStyle())
        #endif
    }
}

enum UserTrackingModes: String {
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

private struct CustomUserLocationButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            content
                .frame(width: 44, height: 44)
                .foregroundStyle(.primary)
                .background(.ultraThinMaterial, in: Circle())
        }
        #else
        // return standard appearance if os is for example watchOS
        content
        #endif
    }
}
