//
//  ErrorPresenter.swift
//  WristMap
//

import SwiftUI
import Observation
import OSLog

struct PresentedAppError: LocalizedError {
    let title: String
    let message: String
    
    var errorDescription: String? {
        title
    }
    
    var failureReason: String? {
        message
    }
}

@MainActor
@Observable
final class ErrorPresenter {
    var error: PresentedAppError?
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "WristMap",
        category: "Errors"
    )
    
    func present(
        _ error: Error,
        title: String,
        message: String
    ) {
        logger.error("Operation failed: \(String(reflecting: error), privacy: .private)")
        
        self.error = PresentedAppError(
            title: title,
            message: message
        )
    }
}
