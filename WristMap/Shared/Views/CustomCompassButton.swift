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
        }
    }
}
