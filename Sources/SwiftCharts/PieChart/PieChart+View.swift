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
        
        let colorValue: ClosedRange<Double> = 0.00...1.00
        var color: Color {
            Color(red: Double.random(in: colorValue), green: Double.random(in: colorValue), blue: Double.random(in: colorValue))
        }
        
        @ObservedObject private var viewModel: PieChart.ViewModel
        @State private var selectedSlice: PieChart.Slice? = nil
        private var backgroundColor: Color
        private var widthFraction: CGFloat
        private var innerRadiusFraction: CGFloat
        
        public init(viewModel: PieChart.ViewModel, backgroundColor: Color = .white, widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60) {
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.widthFraction = widthFraction
            self.innerRadiusFraction = innerRadiusFraction
        }
        
        public var body: some View {
            GeometryReader { geometry in
                pieChart(geometry.size)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
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
                                selectSlice(slice)
                            }
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
                        let midRadians = Double.pi / bigMultiplier - (startAngle + endAngle).radians / bigMultiplier
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
                            .fill(color)
                            if selectedSlice == nil {
                                let percent = String(format: "%.2f", viewModel.getPercent(slice))
                                Text("\(percent)%")
                                    .font(slice.config.textFont)
                                    .foregroundColor(slice.config.textColor)
                                    .position(
                                        x: geometry.size.width * smallMultiplier * CGFloat(mediumMultiplier + smallMultiplier * cos(midRadians)),
                                        y: geometry.size.height * smallMultiplier * CGFloat(mediumMultiplier - smallMultiplier * sin(midRadians))
                                    )
                            }
                        }
                    }
                    
                }
            }
            
            return body
        }
        
        private func infoView(_ slice: PieChart.Slice) -> some View {
            var body: some View {
                VStack {
                    Text(slice.name)
                        .font(slice.config.titleFont)
                        .foregroundColor(slice.config.textColor)
                        .frame(alignment: .center)
                    Text("\(Translations.amount): \(slice.amount)")
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
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .foregroundColor(.black.opacity(0.7))
                )
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
                return 1
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
