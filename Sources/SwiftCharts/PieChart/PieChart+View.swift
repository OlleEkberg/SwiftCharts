//
//  PieChart+View.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation
import SwiftUI

extension PieChart {

    public struct ChartView: View {
        
        @ObservedObject private var viewModel: PieChart.ViewModel
        @State private var selectedSlice: PieChart.Slice? = nil
        @State private var showOtherSheet = false
        private let backgroundColor: Color
        private let type: ChartType
        
        public init(viewModel: PieChart.ViewModel, backgroundColor: Color = .white, type: ChartType = .pie) {
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.type = type
        }
        
        public var body: some View {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    sliceInfo()
                        .frame(width: geometry.size.width, alignment: .leading)
                        .padding([.leading], 12)
                    pieChart(geometry.size)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .sheet(isPresented: $showOtherSheet) {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    Text(Translations.others)
                                        .frame(width: geometry.size.width, alignment: .center)
                                        .font(.largeTitle)
                                        .padding()
                                    Divider()
                                    ForEach(viewModel.smallSlices.slices, id: \.self) { slice in
                                        infoText(slice)
                                            .padding()
                                    }
                                    .padding([.leading, .trailing])
                                }
                            }
                        }
                    Spacer()
                }
            }
        }
        
        func donutChart(_ size: CGSize, config: DonutChart.FractionConfig) -> some View {
            var body: some View {
                ZStack {
                    Circle()
                        .fill(self.backgroundColor)
                        .frame(width: size.width * config.innerRadiusFraction, height: size.width * config.innerRadiusFraction)
                    VStack {
                        Text("Max Amount")
                            .font(.title)
                            .foregroundColor(Color.gray)
                        Text("\(viewModel.maxAmount)")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
            }
            
            return body
        }
        
        func pieChart(_ size: CGSize) -> some View {
            var body: some View {
                ZStack {
                    ForEach(viewModel.slices, id: \.self) { slice in
                        sliceView(slice)
                            .scaleEffect(sliceScale(slice))
                            .blur(radius: sliceBlur(slice))
                            .animation(Animation.spring())
                            .frame(width: size.width * 0.95, height: size.width * 0.95)
                            .onTapGesture {
                                if slice.name == Translations.others {
                                    showOtherSheet = true
                                } else {
                                    selectSlice(slice)
                                }
                            }
                    }
                    if case .donut(let config) = type {
                        donutChart(size, config: config)
                    }
                    if let selectedSlice = selectedSlice {
                        infoView(selectedSlice)
                            .frame(alignment: .leading)
                            .onTapGesture {
                                self.selectedSlice = nil
                            }
                    }
                }
            }
            return body
        }
        
        private func sliceView(_ slice: PieChart.Slice) -> some View {
            
            var body: some View {
                GeometryReader { geometry in
                    if let startAngle = slice.startAngle, let endAngle = slice.endAngle {
                        ZStack {
                            Path { path in
                                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                                let height = width
                                let center = CGPoint(x: width * smallMultiplier, y: height * smallMultiplier)
                                
                                path.move(to: center)
                                path.addArc(
                                    center: center,
                                    radius: width * smallMultiplier,
                                    startAngle: Angle(degrees: -angleDegrees) + startAngle,
                                    endAngle: Angle(degrees: -angleDegrees) + endAngle,
                                    clockwise: false)
                                
                            }
                            .fill(slice.config.sliceColor)
                        }
                    }
                    
                }
            }
            
            return body
        }
        
        private func sliceInfo() -> some View {
            var body: some View {
                ForEach(viewModel.slices, id: \.self) { slice in
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .frame(width: 20, height: 16)
                            .foregroundColor(slice.config.sliceColor)
                        Text(slice.name)
                    }
                    .scaleEffect(sliceScale(slice))
                    .blur(radius: sliceBlur(slice))
                    .animation(Animation.spring())
                    .onTapGesture {
                        if slice.name == Translations.others {
                            showOtherSheet = true
                        } else {
                            selectSlice(slice)
                        }
                    }
                }
            }
            
            return body
        }
        
        private func infoView(_ slice: PieChart.Slice) -> some View {
            var body: some View {
                infoText(slice)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundColor(.black.opacity(0.7))
                )
            }
            
            return body
        }
        
        private func infoText(_ slice: PieChart.Slice) -> some View {
            var body: some View {
                VStack(alignment: .leading) {
                    Text(slice.name)
                        .font(slice.config.titleFont)
                        .foregroundColor(slice.config.textColor)
                        .frame(alignment: .center)
                    let amount = String(format: "%.2f", slice.amount)
                    Text("\(Translations.amount): \(amount)")
                        .font(slice.config.textFont)
                        .foregroundColor(slice.config.textColor)
                    let percent = String(format: "%.2f", viewModel.getPercent(slice))
                    Text("\(Translations.percent): \(percent)%")
                        .font(slice.config.textFont)
                        .foregroundColor(slice.config.textColor)
                    if let additionalInfo = slice.additionalInfo {
                        ForEach(additionalInfo, id: \.self) { info in
                            Text("\(info.name): \(info.value)")
                                .font(slice.config.textFont)
                                .foregroundColor(slice.config.textColor)
                        }
                    }
                }
            }
            
            return body
        }
        
        private func selectSlice(_ slice: PieChart.Slice) {
            guard selectedSlice == nil else {
                selectedSlice = nil
                
                return
            }
            
            selectedSlice = slice
        }
        
        private func sliceScale(_ slice: PieChart.Slice) -> CGFloat {
            guard selectedSlice != nil else {
                return 1
            }
            
            return slice == selectedSlice ? 1.05 : 0.95
        }
        
        private func sliceBlur(_ slice: PieChart.Slice) -> CGFloat {
            guard selectedSlice != nil else {
                return 0
            }
            
            return slice == selectedSlice ? 0 : 8
        }
        
        //MARK: Constants
        let smallMultiplier = 0.5
        let mediumMultiplier = 1.0
        let bigMultiplier = 2.0
        let angleDegrees = 90.0
        let ninetyFivePercent = 95.0
    }
}
