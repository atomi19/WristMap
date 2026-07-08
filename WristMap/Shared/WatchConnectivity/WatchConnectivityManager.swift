//
//  WatchConnectivityManager.swift
//  WristMap
//

import WatchConnectivity
internal import Combine

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    let session = WCSession.default
    var isTransfering = false
    
    override init() {
        super.init()
        
        guard WCSession.isSupported() else { return }
        
        session.delegate = self
        session.activate()
    }
    
    func sendGPXFile(at url: URL) {
        isTransfering = true
        session.transferFile(url, metadata: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func session(
        _ session: WCSession,
        didFinish fileTransfer: WCSessionFileTransfer,
        error: Error?
    ) {
        Task { @MainActor in
            isTransfering = false
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
