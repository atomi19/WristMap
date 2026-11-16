//
//  ElevationChart.swift
//  WristMap
//

import SwiftUI
import Charts

struct ElevationChart: View {
    let elevationPoints: [ElevationPoint]
    
    var body: some View {
        if elevationPoints.count >= 2 {
            Chart(elevationPoints) { point in
                LineMark(
                    x: .value("Distance", point.distance),
                    y: .value("Elevation", point.elevation)
                )
            }
            // limit x by start and end of route (so there is no padding
            .chartXScale(
                domain: 0...max(elevationPoints.last?.distance ?? 0, 1)
            )
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    
                    AxisValueLabel {
                        if let distance = value.as(Double.self) {
                            Text(
                                distance >= 1000
                                ? String(format: "%.1f km", distance / 1000)
                                : "\(Int(distance)) m"
                            )
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    
                    AxisValueLabel {
                        if let elevation = value.as(Double.self) {
                            Text(DataFormatter.shortDistance(elevation))
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding()
        } else {
            Text("Not enough elevation data")
                .foregroundStyle(.secondary)
                .frame(height: 150)
        }
    }
}
