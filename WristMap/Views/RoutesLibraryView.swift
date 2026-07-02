//
//  RoutesLibraryView.swift
//  WristMap
//

import SwiftUI
import SwiftData

struct RoutesLibraryView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Route.createdAt)
    private var routes: [Route]
    
    @State private var isShowingAddRoute = false
    
    let onRouteTap: ([GPXPoint]) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routes) { route in
                    Button {
                        let url = GPXFileManager.fileURL(for: route.uuid)

                        do {
                            let points = try GPXParser().parse(url: url)
                            onRouteTap(points)
                        } catch {
                            print(error)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "map")
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading) {
                                Text(route.routeName)
                                Text("\(route.distance / 1000, specifier: "%.2f") km")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            GPXFileManager.deleteGPXFile(for: route.uuid)
                            context.delete(route)
                            try? context.save()
                        }
                    }
                }
            }
            .navigationTitle("Routes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "plus") {
                        isShowingAddRoute.toggle()
                    }
                }
            }
            .overlay {
                if routes.isEmpty {
                    ContentUnavailableView {
                        Label("No routes yet", systemImage: "map.fill")
                    } description: {
                        Text("Add routes and they will appear here")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddRoute) {
                AddRouteView()
                    .presentationDetents([.medium])
            }
        }
    }
}
