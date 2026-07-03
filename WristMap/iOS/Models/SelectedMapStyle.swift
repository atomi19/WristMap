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
}
