//
//  SettingsView.swift
//  WristMap
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(Settings.Keys.measurementSystem)
    private var selectedUnitRawValue = MeasurementSystem.system.rawValue
    
    @AppStorage(Settings.Keys.appTheme)
    private var selectedThemeRawValue = AppTheme.system.rawValue
    
    private var selectedUnit: Binding<MeasurementSystem> {
        Binding(
            get: {
                MeasurementSystem(rawValue: selectedUnitRawValue) ?? .system
            },
            set: {
                selectedUnitRawValue = $0.rawValue
            }
        )
    }
    
    private var selectedTheme: Binding<AppTheme> {
        Binding(
            get: {
                AppTheme(rawValue: selectedThemeRawValue) ?? .system
            },
            set: {
                selectedThemeRawValue = $0.rawValue
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Appearance", selection: selectedTheme) {
                    Text("System").tag(AppTheme.system)
                    Text("Light").tag(AppTheme.light)
                    Text("Dark").tag(AppTheme.dark)
                }
                .pickerStyle(.navigationLink)
                Picker("Units", selection: selectedUnit) {
                    Text("System").tag(MeasurementSystem.system)
                    Text("Metric").tag(MeasurementSystem.metric)
                    Text("Imperial").tag(MeasurementSystem.imperial)
                }
                .pickerStyle(.navigationLink)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
