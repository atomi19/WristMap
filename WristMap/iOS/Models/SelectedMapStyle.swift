//
//  SelectedMapStyle.swift
//  WristMap
//

import MapKit
import SwiftUI

enum SelectedMapStyle: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case imagery = "Satellite"
    case hybrid = "Hybrid"
    
    var id: String { self.rawValue }
    
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .imagery: return .imagery
        case .hybrid: return .hybrid
        }
    }
        
    var systemImage: String {
        switch self {
        case .standard:
            return "map"
        case .imagery:
            return "globe"
        case .hybrid:
            return "square.2.layers.3d"
        }
    }
}
