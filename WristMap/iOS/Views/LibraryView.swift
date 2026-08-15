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
    let watchManager = WatchConnectivityManager()
    
    @Query
    private var routes: [Route]
    
    var sessions: [Session]
    
    @State private var selectedTab: LibraryTabs = .routes
    
    let onRouteTap: (Route) -> Void
    let onSessionTap: (Session) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
            .navigationTitle(selectedTab == .routes ? "Routes" : "Sessions")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
    let routes: [Route]
    let onRouteTap: (Route) -> Void

    @State private var routeToEdit: Route?
    @State private var routeToDelete: Route?
    
    @State private var searchText: String = ""
    
    // settings
    @State private var sortOptions: RouteSortOptions = Settings.routeSortOption
    
    private var sortedRoutes: [Route] {
        let filteredRoutes = routes.filter { route in
            searchText.isEmpty || // all routes
            route.routeName.localizedStandardContains(searchText) // found routes
        }
        
        switch sortOptions {
        case .dateCreated:
            return filteredRoutes.sorted { $0.createdAt > $1.createdAt }
        case .distanceLowToHigh:
            return filteredRoutes.sorted { $0.distance < $1.distance }
        case .distanceHighToLow:
            return filteredRoutes.sorted { $0.distance > $1.distance }
        case .nameAZ:
            return filteredRoutes.sorted { $0.routeName.localizedStandardCompare($1.routeName) == .orderedAscending }
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedRoutes) { route in
                Button { onRouteTap(route) } label: {
                    let formattedDistance = DataFormatter.distance(route.distance)
                    let formattedDate = route.createdAt.formatted(.dateTime.month(.abbreviated).day())
                    
                    ItemRow(
                        title: route.routeName,
                        subtitle: "\(formattedDistance) • \(formattedDate)",
                        systemImage: "map"
                    )
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
        .searchable(text: $searchText, prompt: "Search")
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
                    Label("No routes yet", systemImage: "map")
                } description: {
                    Text("Add session and it will appear here")
                }
            } else if sortedRoutes.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
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
        .deleteConfirmation(
            isPresented: $isShowingRouteDeleteConfirm,
            title: "Delete Route?",
            onCancel: {
                routeToDelete = nil
            },
            onDelete: {
                if let route = routeToDelete {
                    deleteRoute(route)
                }
                routeToDelete = nil
            }
        )
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
        let filteredSessions: [Session] = sessions.filter { session in
            searchText.isEmpty || // all sessions
            session.name.localizedStandardContains(searchText) // found sessions
        }
        
        switch sortOptions {
        case .dateCreated:
            return filteredSessions.sorted { $0.startedAt > $1.startedAt }
        case .finishedAt:
            return filteredSessions

        case .durationLowToHigh:
            return filteredSessions.sorted { $0.duration < $1.duration }
        case .durationHighToLow:
            return filteredSessions.sorted { $0.duration > $1.duration }

        case .distanceLowToHigh:
            return filteredSessions.sorted { $0.distance < $1.distance }
        case .distanceHighToLow:
            return filteredSessions.sorted { $0.distance > $1.distance }
        }
    }
    
    let onSessionTap: (Session) -> Void
    
    @State private var sessionToEdit: Session?
    @State private var sessionToDelete: Session?
    
    @State private var isShowingSessionDeleteConfirm = false
    
    // settings
    @State private var sortOptions: SessionSortOptions = Settings.sessionSortOption
    
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            ForEach(sortedSessions) { session in
                Button {
                    onSessionTap(session)
                } label: {
                    let formattedDistance = DataFormatter.distance(session.distance)
                    let formattedDuration = DataFormatter.shortDuration(
                        startedAt: session.startedAt,
                        finishedAt: session.finishedAt
                    )
                    
                    ItemRow(
                        title: session.name,
                        subtitle: "\(formattedDistance) • \(formattedDuration)",
                        systemImage: "figure.outdoor.cycle"
                    )
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
        .searchable(text: $searchText, prompt: "Search")
        .sheet(item: $sessionToEdit) { session in
            EditSessionView(session: session)
                .presentationDetents([.medium])
        }
        .overlay {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label("No sessions yet", systemImage: "bicycle.circle")
                } description: {
                    Text("Finish session and it will appear here")
                }
            } else if sortedSessions.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .deleteConfirmation(
            isPresented: $isShowingSessionDeleteConfirm,
            title: "Delete Session?",
            onCancel: {
                sessionToDelete = nil
            },
            onDelete: {
                if let session = sessionToDelete {
                    deleteSession(session)
                }
                sessionToDelete = nil
            }
        )
    }
    
    private func deleteSession(_ session: Session) {
        context.delete(session)
        try? context.save()
    }
}

struct ItemRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 40, height: 40)
                .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

extension View {
    func deleteConfirmation(
        isPresented: Binding<Bool>,
        title: String,
        onCancel: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        self.alert(
            title,
            isPresented: isPresented,
        ) {
            Button("Cancel", role: .cancel) { onCancel() }
            Button("Delete", role: .destructive) { onDelete() }
        } message: {
            Text("This action cannot be undone")
        }
    }
}
