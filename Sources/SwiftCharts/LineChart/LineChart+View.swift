//
//  LineChart+View.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-22.
//

import SwiftUI

extension LineChart {
    public struct ChartView: View {
        
        @ObservedObject private var viewModel: LineChart.ViewModel
        let maxY: Float
        let minY: Float
        
        public init(viewModel: LineChart.ViewModel) {
            self.viewModel = viewModel
            self.maxY = viewModel.largestAmount
            self.minY = viewModel.smallestAmount
            
            print("\(self.maxY) - \(self.minY)")
        }
        
        public var body: some View {
            VStack {
                lineChart
                    .background(lineChartBackground)
                    .overlay(lineChartOverlay, alignment: .leading)
            }
        }
        
        // Constants
        let padding: CGFloat = 2
    }
}

private extension SwiftCharts.LineChart.ChartView {
    var lineChart: some View {
        GeometryReader { geometry in
            Path { path in
                for i in viewModel.points.indices {
                    let xPosition = geometry.size.width / CGFloat(viewModel.points.count) * CGFloat(i + 1)
                    
                    let yAxis = maxY - minY
                    let yPosition = (1 - CGFloat((viewModel.points[i].amount - minY) / yAxis)) * geometry.size.height
                    
                    if i == 0 {
                        path.move(to: .init(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: .init(x: xPosition, y: yPosition))
                }
            }
            .stroke(.black, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
        }
    }
    
    var lineChartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    var lineChartOverlay: some View {
        VStack {
            Text("\(viewModel.largestAmount)")
            Spacer()
            let midAmount = (maxY + minY) / 2
            Text("\(midAmount)")
            Spacer()
            Text("\(viewModel.smallestAmount)")
        }
    }
}
