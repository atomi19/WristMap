//
//  RouteInfoView.swift
//  WristMap
//

import SwiftUI
import CoreLocation

struct RouteInfoView: View {
    let route: Route
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "map")
                .foregroundStyle(.blue)
            
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

#Preview {
    RouteInfoView(
        route: Route(
            routeName: "Route Preview 1",
            gpxFilename: "",
            distance: 25000
        ),
        onClose: {}
    )
}
