//
//  WatchSessionManager.swift
//  WristMap
//

import WatchConnectivity
internal import Combine

final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    let session = WCSession.default
    
    @Published var receivedFile: URL?
    
    override init() {
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {}
    
    func session(
        _ session: WCSession,
        didReceive file: WCSessionFile
    ) {
        let filename = file.fileURL.deletingPathExtension().lastPathComponent
        guard let routeId = UUID(uuidString: filename) else { return }        
        
        do {
            try GPXFileManager.saveGPX(
                from: file.fileURL,
                routeFileId: routeId
            )
            
            DispatchQueue.main.async {
                self.receivedFile = GPXFileManager.fileURL(for: routeId)
            }
        } catch {
            print(error)
        }
    }
}
