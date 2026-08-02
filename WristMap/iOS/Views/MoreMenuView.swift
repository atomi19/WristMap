//
//  MoreMenuView.swift
//  WristMap
//

import SwiftUI

struct MoreMenuView: View {
    @Binding var selectedMapStyle: SelectedMapStyle
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        Menu {
            ControlGroup {
                ForEach(SelectedMapStyle.allCases) { style in
                    Button {
                        selectedMapStyle = style
                    } label: {
                        Label(
                            style.rawValue,
                            systemImage: style.systemImage
                        )
                    }
                }
            }
            Divider()
            Button("Settings", systemImage: "gearshape") {
                activeSheet = .settings
            }
            Button("Library", systemImage: "map") {
                activeSheet = .library
            }
            Button("Session", systemImage: "location.viewfinder") {
                activeSheet = nil
                
                DispatchQueue.main.async {
                    activeSheet = .sessionRecord
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .foregroundStyle(.primary)
    }
}
