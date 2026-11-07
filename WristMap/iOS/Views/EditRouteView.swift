//
//  EditRouteView.swift
//  WristMap
//

import SwiftUI
import SwiftData

struct EditRouteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(ErrorPresenter.self) private var errorPresenter
    
    @State private var name: String
    let route: Route
    
    init(route: Route) {
        self.route = route
        self._name = State(initialValue: route.routeName)
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
                        route.routeName = name
                        
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            errorPresenter.present(
                                error,
                                title: "Failed to save route",
                                message: error.localizedDescription
                            )
                        }
                    }
                )
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
