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
    @State private var didUserSavedRoute = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Route Name", text: $routeName)
                if routeDraft == nil {
                    Button {
                        isShowingFilePicker.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("Add GPX File...")
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    if let draft = routeDraft {
                        HStack {
                            Image(systemName: "map")
                            Text(draft.fileName)
                        }
                    }
                }
            }
            .navigationTitle("Add Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Discard", systemImage: "xmark") {
                        if !routeName.isEmpty || routeDraft != nil {
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
                        guard let draft = routeDraft else { return }
                        
                        do {
                            let route = Route(
                                routeName: routeName,
                                gpxFilename: "",
                                distance: draft.distance
                            )
                            
                            try GPXFileManager.saveGPX(
                                from: draft.temporaryGPXURL,
                                routeFileId: route.uuid
                            )
                            context.insert(route)
                            
                            try context.save()
                            
                            // remove temporary file
                            try? FileManager.default.removeItem(at: draft.temporaryGPXURL)
                            
                            routeDraft = nil
                            routeName = ""
                            
                            didUserSavedRoute = true
                            
                            dismiss()
                        } catch {
                            print(error)
                        }
                    }
                    .disabled(routeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onDisappear {
                // delete temporary file if user discarded route (picked file, but did not saved)
                if !didUserSavedRoute && routeDraft != nil {
                    if let draft = routeDraft {
                        try? FileManager.default.removeItem(at: draft.temporaryGPXURL)
                    }
                }
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
            
            let distance = calculateDistance(points: points)
            
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
    
    private func calculateDistance(points: [GPXPoint]) -> Double{
        guard points.count > 1 else { return 0 }
        
        var total: Double = 0
        
        for i in 1..<points.count {
            let start = CLLocation(
                latitude: points[i - 1].coordinate.latitude,
                longitude: points[i - 1].coordinate.longitude
            )
            
            let end = CLLocation(
                latitude: points[i].coordinate.latitude,
                longitude: points[i].coordinate.longitude
            )
            
            total += start.distance(from: end)
        }
        return total
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
