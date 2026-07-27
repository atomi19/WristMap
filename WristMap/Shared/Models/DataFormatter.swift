//
//  DataFormatter.swift
//  WristMap
//

import Foundation

enum DataFormatter {
    private static var measurementPreference: MeasurementSystem {
        Settings.measurementSystem
    }
    
    static func speed(_ speed: Double) -> String {
        let measurement = Measurement(value: speed, unit: UnitSpeed.metersPerSecond)
        let target: UnitSpeed = measurementPreference.usesMetric ? .kilometersPerHour : .milesPerHour
        let converted = measurement.converted(to: target)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.minimumFractionDigits = 1
        
        return formatter.string(from: converted)
    }
    
    static func distance(_ meters: Double) -> String {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let target: UnitLength = measurementPreference.usesMetric ? .kilometers : .miles
        let converted = measurement.converted(to: target)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        
        return formatter.string(from: converted)
    }
    
    static func duration(_ duration: Double) -> String {
        Duration.seconds(duration).formatted()
    }
    
    static func date(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
