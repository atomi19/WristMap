//
//  GPXParser.swift
//  WristMap
//

import Foundation
import CoreLocation

final class GPXParser: NSObject, XMLParserDelegate {

    private(set) var points: [GPXPoint] = []

    func parse(url: URL) throws -> [GPXPoint] {
        points = []
        
        let parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        parser.parse()
        
        return points
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String]
    ) {
        guard elementName == "trkpt",
              let latString = attributeDict["lat"],
              let lonString = attributeDict["lon"],
              let lat = Double(latString),
              let lon = Double(lonString)
        else { return }

        points.append(
            GPXPoint(
                coordinate: .init(latitude: lat, longitude: lon)
            )
        )
    }
}
