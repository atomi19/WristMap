//
//  LibraryView.swift
//  WristMap
//

import SwiftUI
import SwiftData

private enum LibraryTabs: Int {
    case routes
    case sessions
}

struct LibraryView: View {
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
    @State private var isShowingEditRoute = false
    @State private var isShowingRouteDeleteConfirm = false
    
    let watchManager: WatchConnectivityManager
    var routes: [Route]
    let onRouteTap: (Route) -> Void

    @State private var routeToEdit: Route?
    @State private var routeToDelete: Route?
    
    // settings
    @State private var sortOptions: RouteSortOptions = Settings.routeSortOption
    
    var sortedRoutes: [Route] {
        switch sortOptions {
        case .dateCreated:
            return routes.sorted { $0.createdAt > $1.createdAt }
            
        case .distanceLowToHigh:
            return routes.sorted { $0.distance < $1.distance }
        case .distanceHighToLow:
            return routes.sorted { $0.distance > $1.distance }
        case .nameAZ:
            return routes.sorted { $0.routeName.localizedStandardCompare($1.routeName) == .orderedAscending }
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedRoutes) { route in
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
                    Button("Delete", systemImage: "trash") {
                        routeToDelete = route
                        isShowingRouteDeleteConfirm = true
                    }
                    .tint(.red)
                    Button("Edit", systemImage: "pencil") {
                        routeToEdit = route
                    }
                    .tint(.orange)
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Routes")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sort by", selection: $sortOptions) {
                        Text("A-Z").tag(RouteSortOptions.nameAZ)
                        Text("Most Recent First").tag(RouteSortOptions.dateCreated)
                        Text("Distance High to Low").tag(RouteSortOptions.distanceHighToLow)
                        Text("Distance Low to High").tag(RouteSortOptions.distanceLowToHigh)
                    }
                    .onChange(of: sortOptions) {
                        Settings.routeSortOption = sortOptions
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
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
        .sheet(item: $routeToEdit) { route in
            EditRouteView(route: route)
                .presentationDetents([.medium])
        }
        .alert("Delete Route?", isPresented: $isShowingRouteDeleteConfirm) {
            Button("Cancel") {
                routeToDelete = nil
            }
            Button("Delete") {
                if let route = routeToDelete {
                    deleteRoute(route)
                }
                routeToDelete = nil
            }
        } message: {
            Text("This action cannot be undone")
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
    private var sortedSessions: [Session] {
        switch sortOptions {
        case .dateCreated:
            return sessions.sorted { $0.startedAt > $1.startedAt }
        case .finishedAt:
            return sessions
            
        case .durationLowToHigh:
            return sessions.sorted { $0.duration < $1.duration }
        case .durationHighToLow:
            return sessions.sorted { $0.duration > $1.duration }
            
        case .distanceLowToHigh:
            return sessions.sorted { $0.distance < $1.distance }
        case .distanceHighToLow:
            return sessions.sorted { $0.distance > $1.distance }
        }
    }
    
    let onSessionTap: (Session) -> Void
    
    @State private var sessionToEdit: Session?
    @State private var sessionToDelete: Session?
    
    @State private var isShowingSessionDeleteConfirm = false
    
    // settings
    @State private var sortOptions: SessionSortOptions = Settings.sessionSortOption
    
    var body: some View {
        List {
            ForEach(sortedSessions) { session in
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
                    Button("Delete", systemImage: "trash") {
                        sessionToDelete = session
                        isShowingSessionDeleteConfirm = true
                    }
                    .tint(.red)
                    Button("Edit", systemImage: "pencil") {
                        sessionToEdit = session
                    }
                    .tint(.orange)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sort by", selection: $sortOptions) {
                        Text("Most Recent First").tag(SessionSortOptions.dateCreated)
                        Text("Distance High to Low").tag(SessionSortOptions.distanceHighToLow)
                        Text("Distance Low to High").tag(SessionSortOptions.distanceLowToHigh)
                        Text("Duration High to Low").tag(SessionSortOptions.durationHighToLow)
                        Text("Duration Low to High").tag(SessionSortOptions.durationLowToHigh)
                    }
                    .onChange(of: sortOptions) {
                        Settings.sessionSortOption = sortOptions
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
        }
        .sheet(item: $sessionToEdit) { session in
            EditSessionView(session: session)
                .presentationDetents([.medium])
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
        .alert("Delete Session?", isPresented: $isShowingSessionDeleteConfirm) {
            Button("Cancel") {
                sessionToDelete = nil
            }
            Button("Delete") {
                if let session = sessionToDelete {
                    deleteSession(session)
                }
                sessionToDelete = nil
            }
        } message: {
            Text("This action cannot be undone")
        }
    }
    
    private func deleteSession(_ session: Session) {
        context.delete(session)
        try? context.save()
    }
}
