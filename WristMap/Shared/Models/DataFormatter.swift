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
    
    static func shortDistance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 0
        
        let measurement: Measurement<UnitLength>
        
        if measurementPreference.usesMetric {
            measurement = meters < 1000
            ? Measurement(value: meters, unit: UnitLength.meters)
            : Measurement(value: meters / 1000, unit: .kilometers)
        } else {
            measurement = meters < 1609.34
            ? Measurement(value: meters, unit: .feet)
            : Measurement(value: meters / 1609.34, unit: .miles)
        }
        
        return formatter.string(from: measurement)
    }
    
    static func duration(_ duration: Double) -> String {
        Duration.seconds(duration).formatted()
    }
    
    static func date(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
