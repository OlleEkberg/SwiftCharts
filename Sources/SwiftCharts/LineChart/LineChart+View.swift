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
        @State private var indicatorTextOffset: CGFloat = .zero
        private let config: Config
        private let maxY: Float
        private let minY: Float
        @State var selectedDate = Date()
        @State var showPicker = false
        
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
                // Indicator Calculations
                let segments = geometry.size.width / CGFloat(points.count)
                let pointIndex = value.location.x / segments
                let intIndex = Int(pointIndex) > (points.count - 1) ? points.count - 1 : Int(pointIndex)
                let currentPoint = points[intIndex]
                let xOffset = indicatorRadius
                let yOffset = xOffset - indicatorRadius
                
                indicatorOffset = .init(width: currentPoint.x - xOffset, height: -(geometry.size.height - currentPoint.y + yOffset))
                
                // Text Calculations
                currentIndicatorPositionText = "\(viewModel.points[Int(intIndex)].amount)"
                
                
            }).onEnded({ _ in
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
                .padding(.horizontal, padding)
                .background(
                    Capsule()
                        .foregroundColor(config.backgroundColor.opacity(0.7))
                )
            Spacer()
            let midAmount = (maxY + minY) / 2
            Text(midAmount.twoDigitDecimalString())
                .foregroundColor(config.textColor)
                .padding(.horizontal, padding)
                .background(
                    Capsule()
                        .foregroundColor(config.backgroundColor.opacity(0.7))
                )
            Spacer()
            if config.showChartFloorNumber {
                Text(config.chartFloor.twoDigitDecimalString())
                    .foregroundColor(config.textColor)
                    .padding(.horizontal, padding)
                    .background(
                        Capsule()
                            .foregroundColor(config.backgroundColor.opacity(0.7))
                    )
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
                            .frame(width: filterWidth)
                            .onTapGesture {
                                showPicker = true
                                viewModel.currentFilter = filter
                            }
                            .background(
                                RoundedRectangle(cornerRadius: padding)
                                    .foregroundColor(config.lineColor.opacity(filter == viewModel.currentFilter ? 0.8 : 0.0))
                                
                            )
                            .foregroundColor(config.textColor)
                    } else {
                        Text(filter.name)
                            .frame(width: filterWidth)
                            .onTapGesture {
                                viewModel.currentFilter = filter
                            }
                            .background(
                                RoundedRectangle(cornerRadius: padding)
                                    .foregroundColor(config.lineColor.opacity(filter == viewModel.currentFilter ? 0.8 : 0.0))
                                
                            )
                            .foregroundColor(config.textColor)
                            
                    }
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            Form {
                DatePicker("Select a range of dates", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
        }
    }
    
    var dragIndicator: some View {
        Circle()
            .stroke(lineWidth: indicatorStrokeWidth)
            .fill(config.lineColor)
            .frame(width: indicatorCircleDiameter, height: indicatorCircleDiameter)
            
            .overlay(
                Circle()
                    .frame(width: indicatorCircleCenterDiameter, height: indicatorCircleCenterDiameter)
                    .background(.white)
                    .opacity(0.3)
            )
            .offset(y: indicatorRadius)
            .offset(indicatorOffset)
            .opacity(showIndicator ? 1 : 0)
    }
    
    // MARK: Drawing Constants
    var filterWidth: CGFloat {
        80
    }
    var indicatorCircleDiameter: CGFloat {
        22
    }
    var indicatorStrokeWidth: CGFloat {
        8
    }
    var indicatorCircleCenterDiameter: CGFloat {
        indicatorCircleDiameter - indicatorStrokeWidth
    }
    var indicatorRadius: CGFloat {
        indicatorCircleDiameter / 2
    }
    var padding: CGFloat {
        8
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
