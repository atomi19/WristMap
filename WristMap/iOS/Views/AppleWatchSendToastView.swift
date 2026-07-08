//
//  AppleWatchSendToastView.swift
//  WristMap
//

import SwiftUI

struct AppleWatchSendToastView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Sending to Apple Watch")
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(radius: 3)
    }
}

#Preview {
    AppleWatchSendToastView()
}
