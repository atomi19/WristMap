//
//  MeasurementSystem.swift
//  WristMap
//

import Foundation

enum MeasurementSystem: String {
    case system
    case metric
    case imperial
    
    var usesMetric: Bool {
        switch self {
        case .system:
            return Locale.current.measurementSystem == .metric
        case .metric:
            return true
        case .imperial:
            return false
        }
    }
}
