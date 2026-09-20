//
//  WatchConnectivityManager.swift
//  WristMap
//

import WatchConnectivity
internal import Combine
import SwiftData

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    private let wcSession = WCSession.default
    private var modelContainer: ModelContainer?
    
    var isTransfering: Bool = false
    var receivedFile: URL?
    
    // initialize WatchConnectivity
    public override init() {
        super.init()
        
        guard WCSession.isSupported() else { return }
        
        wcSession.delegate = self
        wcSession.activate()
    }
    
    // give manager access to swift data (for importing sessions and update sync status)
    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    // called when WatchConectivity finished activating
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        if let error { print("WCSession activation failed: \(error.localizedDescription)") }
    }
    
    // send gpx route file to apple watches
    func sendGPXFile(at url: URL) {
        guard wcSession.activationState == .activated else { return }
        isTransfering = true
        wcSession.transferFile(url, metadata: ["type": "gpx"])
    }
    
    #if os(watchOS)
    // convert finished apple watch session to JSON and try to send it to the iphone
    // used after finishing a session and when user presses try again button
    func syncSession(_ session: Session) {
        guard session.recordedOn == .appleWatch, session.finishedAt != nil else { return }
        
        do {
            session.syncStatus = .pending
            
            let data = try JSONEncoder().encode(SessionSyncPayload(session))
            
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(session.uuid.uuidString)
                .appendingPathExtension("json")
            
            try data.write(to: url)
            wcSession.transferFile(url, metadata: ["type": "session", "uuid": session.uuid.uuidString])
        } catch {
            session.syncStatus = .failed
            print("Failed to sync session: \(error.localizedDescription)")
        }
    }
    #endif
    
    // called when file arrives from other device
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let type = file.metadata?["type"] as? String
        
        #if os(watchOS)
        if type == "gpx" {
            receiveGPX(file)
        }
        #endif
        
        #if os(iOS)
        if type == "session" {
            receiveSession(file)
        }
        #endif
    }
    
    #if os(watchOS)
    // save the received GPX into the apple watch local route storage
    private func receiveGPX(_ file: WCSessionFile) {
        let filename = file.fileURL.deletingPathExtension().lastPathComponent
        guard let routeID = UUID(uuidString: filename) else { return }
        
        do {
            try GPXFileManager.saveGPX(from: file.fileURL, routeFileId: routeID)
            
            Task { @MainActor in
                self.receivedFile = GPXFileManager.fileURL(for: routeID)
            }
        } catch {
            print("Failed to receive GPX file: \(error.localizedDescription)")
        }
    }
    #endif
    
    #if os(iOS)
    // decode JSON file received from apple watches
    private func receiveSession(_ file: WCSessionFile) {
        do {
            let data = try Data(contentsOf: file.fileURL)
            let payload = try JSONDecoder().decode(SessionSyncPayload.self, from: data)
            
            Task { @MainActor in
                self.importSession(payload)
            }
        } catch {
            print("Failed to decode session: \(error.localizedDescription)")
        }
    }
    
    // create swift data session from the received JSON
    @MainActor
    private func importSession(_ payload: SessionSyncPayload) {
        guard let context = modelContainer?.mainContext else { return }
        
        do {
            let id = payload.uuid
            let descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.uuid == id })
            
            if try context.fetch(descriptor).first != nil {
                sendACK(for: id)
                return
            }
            
            let newSession = Session()
            newSession.uuid = payload.uuid
            newSession.name = payload.name
            newSession.distance = payload.distance
            newSession.startedAt = payload.startedAt
            newSession.finishedAt = payload.finishedAt
            newSession.duration = payload.duration
            newSession.movingDuration = payload.movingDuration
            newSession.averageSpeed = payload.averageSpeed
            newSession.maxSpeed = payload.maxSpeed
            newSession.recordedOn = .appleWatch
            newSession.syncStatus = .notApplicable
            
            newSession.sessionPoints = payload.points.map {
                SessionPoint(
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    elevation: $0.elevation,
                    speed: $0.speed,
                    timestamp: $0.timestamp
                )
            }
            
            context.insert(newSession)
            try context.save()
            
            sendACK(for: payload.uuid)
        } catch {
            print("Failed to import session: \(error.localizedDescription)")
        }
    }
    
    // send acknowledgement back to apple watch (status)
    private func sendACK(for uuid: UUID) {
        guard wcSession.activationState == .activated else { return }
        wcSession.transferUserInfo(["type": "sessionAck", "uuid": uuid.uuidString])
    }
    #endif
    
    // called when apple watch receives acknowledgement from iphone
    // and find which session acknowledgment belongs to and update sync status
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        #if os(watchOS)
        guard userInfo["type"] as? String == "sessionAck",
              let value = userInfo["uuid"] as? String,
              let uuid = UUID(uuidString: value) else { return }
        
        Task { @MainActor in
            self.markSynced(uuid)
        }
        #endif
    }
    
    #if os(watchOS)
    
    // find session and save its new sync status (pending/synced/failed label)
    @MainActor
    private func markSynced(_ uuid: UUID) {
        guard let context = modelContainer?.mainContext else { return }
        
        do {
            let id = uuid
            let descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.uuid == id })
            
            if let session = try context.fetch(descriptor).first {
                session.syncStatus = .synced
                try context.save()
            }
        } catch {
            print("Failed to update sync status: \(error.localizedDescription)")
        }
    }
    #endif
    
    // called when file transfer finishes or fails
    func session(
        _ session: WCSession,
        didFinish fileTransfer: WCSessionFileTransfer,
        error: Error?
    ) {
        if fileTransfer.file.metadata?["type"] as? String == "gpx" {
            Task { @MainActor in
                self.isTransfering = false
            }
        }
        
        if let error {
            print("Failed to transfer file: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    
    // check whether apple watch is paired and has ios app installed
    var canShareToWatch: Bool {
        WCSession.isSupported() &&
        wcSession.isPaired &&
        wcSession.isWatchAppInstalled
    }
    #endif
}
