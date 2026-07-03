//
//  Settings.swift
//  WristMap
//

import Foundation
import MapKit

enum Settings {
    private enum SettingsKeys {
        static let mapStyle = "mapStyle"
    }
    
    static var mapStyle: SelectedMapStyle {
        get {
            SelectedMapStyle(
                rawValue: UserDefaults.standard.string(forKey: SettingsKeys.mapStyle) ?? ""
            ) ?? .standard
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SettingsKeys.mapStyle)
        }
    }
}
