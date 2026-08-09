//
//  EditToolbarView.swift
//  WristMap
//

import SwiftUI

struct EditToolbarView: ToolbarContent {
    let canSave: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark") {
                onCancel()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", systemImage: "checkmark") {
                onSave()
            }
            .disabled(canSave)
        }
    }
}
