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
    
    let onRouteTap: (Route) -> Void
    
    let watchManager = WatchConnectivityManager()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routes) { route in
                    Button { onRouteTap(route) } label: {
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
                    .swipeActions(edge: .leading) {
                        Button("Send to Watch", systemImage: "applewatch") {
                            sendToWatch(route)
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteRoute(route)
                        }
                    }
                }
            }
            .navigationTitle("Routes")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
            .overlay(alignment: .bottom) {
                 if watchManager.isTransfering {
                     AppleWatchSendToastView()
                }
            }
            .sheet(isPresented: $isShowingAddRoute) {
                AddRouteView()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func deleteRoute(_ route: Route) {
        GPXFileManager.deleteGPXFile(for: route.uuid)
        context.delete(route)
        try? context.save()
    }
    
    private func sendToWatch(_ route: Route) {
        let url = GPXFileManager.fileURL(for: route.uuid)
        
        watchManager.sendGPXFile(at: url)
    }
}
