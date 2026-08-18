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
                .frame(width: 32, height: 32)
        }
        .modifier(MoreMenuButtonStyle())
    }
}

private struct MoreMenuButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            content
                .frame(width: 44, height: 44)
                .foregroundStyle(.primary)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
