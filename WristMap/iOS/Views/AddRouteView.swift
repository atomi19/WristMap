//
//  AddRouteView.swift
//  WristMap
//

import SwiftUI
internal import UniformTypeIdentifiers
import SwiftData
import CoreLocation

struct AddRouteView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var routeName = ""
    @State private var isShowingFilePicker = false
    @State private var routeDraft: RouteDraft?
    @State private var isShowingDiscardDialog = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // form
                Form {
                    Section("Route Details") {
                        TextField("Route Name", text: $routeName)
                    }
                    
                    if let draft = routeDraft {
                        Section("GPX File") {
                            Label(draft.fileName, systemImage: "map")
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: false
                                ) {
                                    Button(role: .destructive) {
                                        deleteTemporaryGPX()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                // add gpx route button
                if routeDraft == nil {
                    Button {
                        isShowingFilePicker = true
                    } label: {
                        Text("Add GPX File")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.blue, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Add Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Discard", systemImage: "xmark") {
                        if !routeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            routeDraft != nil
                        {
                            isShowingDiscardDialog = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog(
                        "Discard Route",
                        isPresented: $isShowingDiscardDialog,
                    ) {
                        Button("Discard Route", role: .destructive) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm", systemImage: "checkmark") {
                        saveRoute()
                    }
                    .disabled(
                        routeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        routeDraft == nil
                    )
                }
            }
            .onDisappear {
                // delete temporary file if user discarded route (picked file, but did not saved)
                deleteTemporaryGPX()
            }
            .fileImporter(
                isPresented: $isShowingFilePicker,
                allowedContentTypes: [.xml, .item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importFile(from: url)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func saveRoute() {
        guard let draft = routeDraft else { return }
        
        let route = Route(
            routeName: routeName,
            gpxFilename: "",
            distance: draft.distance
        )
        
        do {
            try GPXFileManager.saveGPX(
                from: draft.temporaryGPXURL,
                routeFileId: route.uuid
            )
            context.insert(route)
            
            do {
                try context.save()
            } catch {
                context.delete(route)
                GPXFileManager.deleteGPXFile(for: route.uuid)
                throw error
            }
            
            deleteTemporaryGPX()
            routeName = ""
            dismiss()
        } catch {
            print("Failed to save route: \(error)")
        }
    }
    
    private func importFile(from url: URL) {
        do {
            let originalFileName: String = url.deletingPathExtension().lastPathComponent
            
            guard url.startAccessingSecurityScopedResource() else {return}
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            let tempURL = GPXFileManager.temporaryFileURL()
            
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            try FileManager.default.copyItem(
                at: url,
                to: tempURL
            )
            
            let points = try GPXParser().parse(url: url)
            let distance = RouteDistanceMarkerCalculator.calculateDistance(points: points)
            
            routeDraft = RouteDraft(
                routeName: routeName,
                fileName: originalFileName,
                temporaryGPXURL: tempURL,
                distance: distance
            )
        } catch {
            print(error)
        }
    }
    
    private func deleteTemporaryGPX() {
        guard let draft = routeDraft else {return}
        
        try? FileManager.default.removeItem(
            at: draft.temporaryGPXURL
        )
        
        routeDraft = nil
    }
}

private struct RouteDraft {
    var id: UUID = UUID()
    var routeName: String
    var fileName: String
    var temporaryGPXURL: URL
    var distance: Double
}

#Preview {
    AddRouteView()
}
