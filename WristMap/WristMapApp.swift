//
//  WristMapApp.swift
//  WristMap
//

import SwiftUI
import SwiftData

@main
struct WristMapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Route.self)
    }
}
