//
//  SessionDetailRow.swift
//  WristMap Watch App
//

import SwiftUI

struct SessionDetailRow: View {
    let title: String
    let data: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(data)
                    .font(.system(size: 25, weight: .bold))
                    .monospacedDigit()
            }
        }
    }
}
