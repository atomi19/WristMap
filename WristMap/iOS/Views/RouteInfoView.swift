//
//  RouteInfoView.swift
//  WristMap
//

import SwiftUI
import CoreLocation

struct RouteInfoView: View {
    let route: Route
    @Binding var isRouteRecenterActive: Bool
    let onClose: () -> Void
    let onRouteRecenter: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRouteRecenter) {
                Image(systemName: isRouteRecenterActive ? "map.fill" : "map")
            }
            
            VStack(alignment: .leading) {
                Text(route.routeName)
                Text("\(route.distance / 1000, specifier: "%.2f") km")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .clipShape(.capsule)
    }
}
