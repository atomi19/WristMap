//
//  DataFormatter.swift
//  WristMap
//

import Foundation


enum DataFormatter {
    static func speed(_ speed: Double) -> String {
        String(format: "%.1f km/h", speed * 3.6)
    }
    
    static func distance(_ meters: Double) -> String {
        String(format: "%.2f km", meters / 1000)
    }
    
    static func duration(_ duration: Double) -> String {
        Duration.seconds(duration).formatted()
    }
    
    static func date(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}
