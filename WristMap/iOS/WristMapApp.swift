//
//  WristMapApp.swift
//  WristMap
//

import SwiftUI
import SwiftData

@main
struct WristMapApp: App {
    @State private var watchConnectivityManager = WatchConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView_iOS()
                .environment(watchConnectivityManager)
        }
        .modelContainer(for: Route.self)
    }
}
