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
        @State private var currentIndicatorPositionText = ""
        @State private var indicatorOffset: CGSize = .zero
        @State private var showIndicator: Bool = false
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
                    .overlay(lineChartOverlay, alignment: .trailing)
                lineChartDates()
                chartFilter()
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
            .overlay(dragIndicator, alignment: .bottomLeading)
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged({ value in
                
                withAnimation {
                    showIndicator = true
                }
                let translation = value.location.x - 40
                let width = geometry.size.width / CGFloat(viewModel.points.count - 1)
                
                let index = max(min(Int(translation / width) + 1, viewModel.points.count - 1), 0)
                currentIndicatorPositionText = "\(viewModel.points[index].amount)"
                
                indicatorOffset = .init(width: points[index].x - 40, height: 0)//points[index].y )//- geometry.size.height)
            }).onEnded({ value in
                withAnimation {
                    showIndicator = false
                }
            }))
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
            if config.showChartFloorNumber {
                Text(config.chartFloor.twoDigitDecimalString())
                    .foregroundColor(config.textColor)
            }
        }
    }
    
    @ViewBuilder
    func lineChartDates() -> some View {
        if let firstDate = viewModel.firstDate,
              let latestDate = viewModel.latestDate {
            VStack {
                HStack {
                    Text(viewModel.formatDate(firstDate, format: config.dateFormat))
                        .foregroundColor(config.textColor)
                    Spacer()
                    Text(viewModel.formatDate(latestDate, format: config.dateFormat))
                        .foregroundColor(config.textColor)
                }
                Divider()
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func chartFilter() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(LineChart.ViewModel.Filter.allCases, id: \.self) { filter in
                    if filter == .custom {
                        Image(systemName: "calendar")
                            .frame(width: 80)
                            .onTapGesture {
                                
                            }
                            .foregroundColor(config.textColor)
                    } else {
                        Text(filter.name)
                            .frame(width: 80)
                            .onTapGesture {
                                viewModel.currentFilter = filter
                            }
                            .foregroundColor(config.textColor)
                    }
                }
            }
        }
    }
    
    var dragIndicator: some View {
        VStack(spacing: 0) {
            Text(currentIndicatorPositionText)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .foregroundColor(config.lineColor)
                )
            
            Rectangle()
                .fill(config.lineColor)
                .frame(width: 1, height: 45)
                .padding(.top)
            
            Circle()
                .fill(config.lineColor)
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .fill(config.backgroundColor)
                        .frame(width: 10, height: 10)
                )
        }
        .frame(width: 80, height: 170)
//        .offset(y: 70)
        .offset(indicatorOffset)
        .opacity(showIndicator ? 1 : 0)
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
