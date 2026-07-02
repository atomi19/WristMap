//
//  GPXFileManager.swift
//  WristMap
//

import Foundation

enum GPXFileManager {
    static let directory: URL = {
        let url = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
            .appendingPathComponent("Routes")
        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        
        return url
    }()
    
    static func fileURL(for id: UUID) -> URL {
        directory.appendingPathComponent("\(id.uuidString).gpx")
    }
    
    static func saveGPX(from sourceURL: URL, routeFileId: UUID) throws {
        let destination = fileURL(for: routeFileId)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        
        try FileManager.default.copyItem(at: sourceURL, to: destination)
    }
    
    static func deleteGPXFile(for id: UUID) {
        let url = fileURL(for: id)
        try? FileManager.default.removeItem(at: url)
    }
    
    static func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(".gpx")
    }
}
