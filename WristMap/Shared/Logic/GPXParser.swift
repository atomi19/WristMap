//
//  GPXParser.swift
//  WristMap
//

import Foundation
import CoreLocation

final class GPXParser: NSObject, XMLParserDelegate {
    private(set) var points: [GPXPoint] = []
    private var currentValue = ""
    private var currentPoint: GPXPoint?

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
        currentValue = ""
        
        if elementName == "trkpt",
           let latString = attributeDict["lat"],
           let lonString = attributeDict["lon"],
           let lat = Double(latString),
           let lon = Double(lonString)
        {
            currentPoint = GPXPoint(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                elevation: nil
            )
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "ele":
            currentPoint?.elevation = Double(currentValue.trimmingCharacters(in: .whitespacesAndNewlines))
        case "trkpt":
            if let point = currentPoint {
                points.append(point)
            }
            currentPoint = nil
        default:
            break
        }
    }
}
