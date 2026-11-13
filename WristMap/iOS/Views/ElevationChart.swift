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
            // limit x by start and end of route (so there is no padding inside the chart)
            .chartXScale(domain: elevationPoints.first!.distance...elevationPoints.last!.distance)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    
                    AxisValueLabel {
                        if let distance = value.as(Double.self) {
                            Text(DataFormatter.shortDistance(distance))
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
