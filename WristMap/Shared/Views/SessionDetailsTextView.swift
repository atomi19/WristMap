//
//  SessionDetailsTextView.swift
//  WristMap
//

import SwiftUI

struct SessionDetailsTextView: View {
    let label: String
    let dataText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(dataText)
                .font(.title3)
        }
    }
}
