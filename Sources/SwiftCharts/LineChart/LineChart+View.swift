//
//  LineChart+View.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-22.
//

import SwiftUI
import XCTest

extension LineChart {
    public struct ChartView: View {
        
        @ObservedObject private var viewModel: LineChart.ViewModel
        private let config: Config
        private let maxY: Float
        private let minY: Float
        
        public init(viewModel: LineChart.ViewModel, config: LineChart.Config = .init()) {
            self.viewModel = viewModel
            self.config = config
            self.maxY = viewModel.largestAmount + config.extraHeadSpace
            self.minY = config.chartFloor
        }
        
        public var body: some View {
            VStack {
                lineChart()
                    .background(lineChartBackground)
                    .overlay(lineChartOverlay, alignment: .leading)
                lineChartDates
            }
        }
    }
}

// MARK: Views
private extension SwiftCharts.LineChart.ChartView {
    
    func lineChart() -> some View {
        GeometryReader { geometry in
            let points = createPoints(with: geometry.size)
            ZStack {

                Path { path in
                    path.move(to: .init(x: 0, y: 0))
                    path.addLines(points)
                }
                .stroke(config.lineColor, style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, lineJoin: .round))
                if config.gradientUnderChart {
                    lineGradient(size: geometry.size, points: points)
                }
            }
        }
    }
    
    func lineGradient(size: CGSize, points: [CGPoint]) -> some View {
        LinearGradient(colors:
                        [
                            config.lineColor.opacity(0.3),
                            config.lineColor.opacity(0.2),
                            config.lineColor.opacity(0.1)
                        ], startPoint: .top, endPoint: .bottom)
        .clipShape (
            Path { path in
                path.move(to: .init(x: 0, y: 0))
                path.addLines(points)
                path.addLine(to: .init(x: size.width, y: size.height))
                path.addLine(to: .init(x: 0, y: size.height))
            }
        )
    }
    
    var lineChartBackground: some View {
        VStack {
            Divider()
                .foregroundColor(config.dividerColor)
            Spacer()
            Divider()
                .foregroundColor(config.dividerColor)
            Spacer()
            Divider()
                .foregroundColor(config.dividerColor)
        }
    }
    
    var lineChartOverlay: some View {
        VStack {
            Text((viewModel.largestAmount + config.extraHeadSpace).twoDigitDecimalString())
                .foregroundColor(config.textColor)
            Spacer()
            let midAmount = (maxY + minY) / 2
            Text(midAmount.twoDigitDecimalString())
                .foregroundColor(config.textColor)
            Spacer()
            Text(config.chartFloor.twoDigitDecimalString())
                .foregroundColor(config.textColor)
        }
    }
    
    var lineChartDates: some View {
        HStack {
            if let firstDate = viewModel.firstDate,
                  let latestDate = viewModel.latestDate {
                Text(viewModel.formatDate(firstDate, format: config.dateFormat))
                    .foregroundColor(config.textColor)
                Spacer()
                Text(viewModel.formatDate(latestDate, format: config.dateFormat))
                    .foregroundColor(config.textColor)
            }
        }
    }
    
    
}

// MARK: Calculations
private extension LineChart.ChartView {
    func createPoints(with size: CGSize) -> [CGPoint] {
        var points = [CGPoint]()
        for i in viewModel.points.indices {
            let segments = CGFloat(viewModel.points.count - 1)
            let xPosition = size.width / segments * CGFloat(i)
            
            let yAxis = maxY - minY
            let yPosition = (1 - CGFloat((viewModel.points[i].amount - minY) / yAxis)) * size.height
            points.append(.init(x: xPosition, y: yPosition))
        }
        return points
    }
}
