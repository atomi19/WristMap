//
//  RoutesLibraryView.swift
//  WristMap
//

import SwiftUI
import SwiftData

private enum LibraryTabs: Int {
    case routes
    case sessions
}

struct RoutesLibraryView: View {
    @Environment(\.modelContext) private var context
    let watchManager = WatchConnectivityManager()
    
    @Query(sort: \Route.createdAt)
    private var routes: [Route]
    var sessions: [Session]
    
    @State private var isShowingAddRoute = false
    @State private var selectedTab: LibraryTabs = .routes
    
    let onRouteTap: (Route) -> Void
    let onSessionTap: (Session) -> Void
    
    var body: some View {
        NavigationStack {
            Picker("", selection: $selectedTab) {
                Text("Routes").tag(LibraryTabs.routes)
                Text("Sessions").tag(LibraryTabs.sessions)
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedTab {
            case .routes:
                RoutesListView(
                    watchManager: watchManager,
                    routes: routes,
                    onRouteTap: onRouteTap
                )
            case .sessions:
                SessionsListView(
                    sessions: sessions,
                    onSessionTap: { onSessionTap($0) }
                )
            }
        }
    }
}

// imported gpx routes
struct RoutesListView: View {
    @Environment(\.modelContext) private var context
    @State private var isShowingAddRoute = false
    
    let watchManager: WatchConnectivityManager
    var routes: [Route]
    let onRouteTap: (Route) -> Void
    
    var body: some View {
        List {
            ForEach(routes) { route in
                Button { onRouteTap(route) } label: {
                    HStack {
                        Image(systemName: "map")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(route.routeName)
                            Text(DataFormatter.distance(route.distance))
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
        .background(Color(.systemBackground))
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
    
    private func sendToWatch(_ route: Route) {
        let url = GPXFileManager.fileURL(for: route.uuid)
        
        watchManager.sendGPXFile(at: url)
    }
    
    private func deleteRoute(_ route: Route) {
        GPXFileManager.deleteGPXFile(for: route.uuid)
        context.delete(route)
        try? context.save()
    }
}

// completed sessions
struct SessionsListView: View {
    @Environment(\.modelContext) private var context
    
    var sessions: [Session]
    let onSessionTap: (Session) -> Void
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                Button {
                    onSessionTap(session)
                } label: {
                    HStack {
                        Image(systemName: "map")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text("\(session.name)")
                            Text("Started \(DataFormatter.date(session.startedAt))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(DataFormatter.distance(session.distance))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteSession(session)
                    }
                }
            }
        }
        .navigationTitle("Sessions")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .overlay {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label("No sessions yet", systemImage: "bicycle.circle")
                } description: {
                    Text("Finish session and it will appear here")
                }
            }
        }
    }
    
    private func deleteSession(_ session: Session) {
        context.delete(session)
        try? context.save()
    }
}
