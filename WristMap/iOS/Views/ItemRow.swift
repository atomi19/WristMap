//
//  ItemRow.swift
//  WristMap
//

import Foundation
import SwiftUI

struct ItemRow: View {
    let recordedOn: RecordingSource?
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 40, height: 40)
                .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if recordedOn == .appleWatch {
                Image(systemName: "applewatch")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
