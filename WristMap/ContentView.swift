//
//  ContentView.swift
//  WristMap
//

import SwiftUI
import MapKit
internal import UniformTypeIdentifiers
import CoreLocation
import Foundation

struct ContentView: View {
    @State private var isShowingFilePicker = false
    @State private var points: [GPXPoint] = []
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var selectedMapStyle: SelectedMapStyle = .standard

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                if points.count > 1 {
                    MapPolyline(coordinates: points.map(\.coordinate))
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapScaleView()
            }
            .mapStyle(selectedMapStyle.mapStyle)
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        Picker("Map Style", selection: $selectedMapStyle) {
                            ForEach(SelectedMapStyle.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        Button("Import GPX", systemImage: "square.and.arrow.down") {
                            isShowingFilePicker.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .fileImporter(
                isPresented: $isShowingFilePicker,
                allowedContentTypes: [.xml, .item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let data = try Data(contentsOf: url)
                        
                        let parser = GPXParser()
                        self.points = parser.parse(data: data)
                    } catch {
                        print("Error:", error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

enum SelectedMapStyle: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case imagery = "Satellite"
    case hybrid = "Hybrid"
    
    var id: String { self.rawValue }
    
    var mapStyle: MapStyle {
        switch self {
        case .standard: return .standard
        case .imagery: return .imagery
        case .hybrid: return .hybrid
        }
    }
}

struct GPXPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

final class GPXParser: NSObject, XMLParserDelegate {
    private(set) var points: [GPXPoint] = []
    private var lat: Double?
    private var lon: Double?
    
    func parse(data: Data) -> [GPXPoint] {
        points.removeAll()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return points
    }
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        if elementName == "trkpt" {
            lat = Double(attributeDict["lat"] ?? "")
            lon = Double(attributeDict["lon"] ?? "")
        }
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "trkpt", let lat, let lon {
            points.append(
                GPXPoint(
                    coordinate: .init(latitude: lat, longitude: lon)
                )
            )
        }
    }
}

#Preview {
    ContentView()
}
