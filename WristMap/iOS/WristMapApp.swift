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
    @State private var errorPresenter = ErrorPresenter()
    
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
                .environment(errorPresenter)
                .preferredColorScheme(appTheme.colorScheme)
                .alert(error: $errorPresenter.error) {_ in  
                    Button("OK", role: .cancel) {}
                } message: { error in
                    Text(error.failureReason ?? "")
                }
        }
        .modelContainer(modelContainer)
    }
}
