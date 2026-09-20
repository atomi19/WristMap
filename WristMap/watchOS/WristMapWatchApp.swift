//
//  WristMap_Watch_AppApp.swift
//  WristMap Watch App Watch App
//

import SwiftUI
import SwiftData

@main
struct WristMapWatchApp: App {
    private let modelContainer: ModelContainer
    @State private var watchConnectivityManager: WatchConnectivityManager
    
    init() {
        let container = try! ModelContainer(for: Session.self)
        let manager = WatchConnectivityManager()
        
        manager.configure(modelContainer: container)
        modelContainer = container
        _watchConnectivityManager = State(initialValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView_watchOS()
                .environment(watchConnectivityManager)
        }
        .modelContainer(modelContainer)
    }
}
