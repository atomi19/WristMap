//
//  WristMapApp.swift
//  WristMap
//

import SwiftUI
import SwiftData

@main
struct WristMapApp: App {
    @State private var watchConnectivityManager = WatchConnectivityManager()
    
    // app theme
    @AppStorage(Settings.Keys.appTheme)
    private var appThemeRawValue = AppTheme.system.rawValue
    
    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRawValue) ?? .system
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView_iOS()
                .environment(watchConnectivityManager)
                .preferredColorScheme(appTheme.colorScheme)
        }
        .modelContainer(for: [Route.self, Session.self])
    }
}
