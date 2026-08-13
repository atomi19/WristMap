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
        static let routeSortOption = "routeSortOption"
        static let sessionSortOption = "sessionSortOption"
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
    
    static var routeSortOption: RouteSortOptions {
        get {
            RouteSortOptions(
                rawValue: UserDefaults.standard.string(forKey: Keys.routeSortOption) ?? ""
            ) ?? .dateCreated
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.routeSortOption)
        }
    }
    
    static var sessionSortOption: SessionSortOptions {
        get {
            SessionSortOptions(
                rawValue: UserDefaults.standard.string(forKey: Keys.sessionSortOption) ?? ""
            ) ?? .dateCreated
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.sessionSortOption)
        }
    }
}
