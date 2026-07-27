//
//  SettingsView.swift
//  WristMap
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedUnit: MeasurementSystem = Settings.measurementSystem
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Units", selection: $selectedUnit) {
                    Text("System").tag(MeasurementSystem.system)
                    Text("Metric").tag(MeasurementSystem.metric)
                    Text("Imperial").tag(MeasurementSystem.imperial)
                }
                .pickerStyle(.navigationLink)
                .onChange(of: selectedUnit) { _, newValue in
                    Settings.measurementSystem = newValue
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
