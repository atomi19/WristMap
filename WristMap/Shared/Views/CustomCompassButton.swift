//
//  CustomCompassButton.swift
//  WristMap
//

import SwiftUI
import CoreLocation

struct CustomCompassButton: View {
    let heading: CLLocationDirection
    let resetHeading: () -> Void
    
    var body: some View {
        Button(action: resetHeading) {
            Image(systemName: "safari")
                .rotationEffect(.degrees(-heading - 45))
                .frame(width: 32, height: 32)
        }
        .modifier(CustomCompassButtonStyle())
    }
}

private struct CustomCompassButtonStyle: ViewModifier {
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
