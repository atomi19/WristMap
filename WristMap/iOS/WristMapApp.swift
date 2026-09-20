//
//  WristMapApp.swift
//  WristMap
//

import SwiftUI
import SwiftData

@main
struct WristMapApp: App {
    private let modelContainer: ModelContainer
    @State private var watchConnectivityManager: WatchConnectivityManager
    
    // app theme
    @AppStorage(Settings.Keys.appTheme)
    private var appThemeRawValue = AppTheme.system.rawValue
    
    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .system
    }
    
    init() {
        let container = try! ModelContainer(for: Route.self, Session.self)
        let manager = WatchConnectivityManager()
        
        manager.configure(modelContainer: container)
        modelContainer = container
        _watchConnectivityManager = State(initialValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView_iOS()
                .environment(watchConnectivityManager)
                .preferredColorScheme(appTheme.colorScheme)
        }
        .modelContainer(modelContainer)
    }
}
