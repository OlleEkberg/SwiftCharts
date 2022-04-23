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
        private let config: Config
        private let maxY: Float
        private let minY: Float
        
        public init(viewModel: LineChart.ViewModel, config: LineChart.Config = .init()) {
            self.viewModel = viewModel
            self.config = config
            self.maxY = viewModel.largestAmount
            self.minY = viewModel.smallestAmount
        }
        
        public var body: some View {
            VStack {
                lineChart
                    .background(lineChartBackground)
                    .overlay(lineChartOverlay, alignment: .leading)
                lineChartUnderLay
            }
        }
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
                    print(xPosition)
                    if i == 0 {
                        path.move(to: .init(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: .init(x: xPosition, y: yPosition))
                }
            }
            .stroke(config.lineColor, style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, lineJoin: .round))
        }
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
            Text(viewModel.largestAmount.twoDigitDecimalString())
                .foregroundColor(config.textColor)
            Spacer()
            let midAmount = (maxY + minY) / 2
            Text(midAmount.twoDigitDecimalString())
                .foregroundColor(config.textColor)
            Spacer()
            Text(viewModel.smallestAmount.twoDigitDecimalString())
                .foregroundColor(config.textColor)
        }
    }
    
    var lineChartUnderLay: some View {
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
