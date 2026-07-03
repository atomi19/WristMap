//
//  Route.swift
//  WristMap
//

import Foundation
import SwiftData

@Model
class Route {
    var uuid: UUID = UUID()
    var routeName: String
    var gpxFilename: String
    var createdAt: Date = Date.now
    var distance: Double
    
    init(routeName: String, gpxFilename: String, distance: Double) {
        self.routeName = routeName
        self.gpxFilename = gpxFilename
        self.distance = distance
    }
}
