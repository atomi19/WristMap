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
                .font(.subheadline)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

#Preview {
    AppleWatchSendToastView()
}
