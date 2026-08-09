//
//  EditSessionView.swift
//  WristMap
//

import SwiftUI
import SwiftData

struct EditSessionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    let session: Session
    
    init(session: Session) {
        self.session = session
        self._name = State(initialValue: session.name)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
            }
            .toolbar {
                EditToolbarView(
                    canSave: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    onCancel: { dismiss() },
                    onSave: {
                        session.name = name
                        
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            print(error)
                        }
                    }
                )
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
