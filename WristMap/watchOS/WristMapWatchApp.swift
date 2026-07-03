//
//  WristMap_Watch_AppApp.swift
//  WristMap Watch App Watch App
//

import SwiftUI
import SwiftData

@main
struct WristMapWatchApp: App {
    @State private var watchConnectivityManager = WatchConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView_watchOS()
                .environment(watchConnectivityManager)
        }
    }
}
