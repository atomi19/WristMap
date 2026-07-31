//
//  Settings.swift
//  WristMap
//

import Foundation
import MapKit

enum Settings {
    enum Keys {
        static let mapStyle = "mapStyle"
        static let measurementSystem = "measurementSystem"
        static let appTheme = "appTheme"
    }
    
    // map style
    static var mapStyle: SelectedMapStyle {
        get {
            SelectedMapStyle(
                rawValue: UserDefaults.standard.string(forKey: Keys.mapStyle) ?? ""
            ) ?? .standard
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.mapStyle)
        }
    }
    
    // measurement system
    static var measurementSystem: MeasurementSystem {
        get {
            MeasurementSystem(
                rawValue: UserDefaults.standard.string(forKey: Keys.measurementSystem) ?? ""
            ) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.measurementSystem)
        }
    }
    
    static var appTheme: AppTheme {
        get {
            AppTheme(
                rawValue: UserDefaults.standard.string(forKey: Keys.appTheme) ?? ""
            ) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.appTheme)
        }
    }
}
