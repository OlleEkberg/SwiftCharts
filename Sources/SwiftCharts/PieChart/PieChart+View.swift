//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation
import SwiftUI

extension PieChart {

    public struct ChartView: View {
        
        let colors: [Color] = [.red, .blue, .green, .yellow]
        
        @ObservedObject private var viewModel: PieChart.ViewModel
        @State private var title: String = "Total"
//        @State private var amount: String
        @State private var tappedSlice: PieChart.Slice? = nil {
            didSet {
                self.previouslyTappedSlice = oldValue
            }
        }
        @State private var previouslyTappedSlice: PieChart.Slice? = nil
//        private let formatter: (Double) -> String
        private var backgroundColor: Color
        private var widthFraction: CGFloat
        private var innerRadiusFraction: CGFloat
        
        public init(viewModel: PieChart.ViewModel, backgroundColor: Color = .white, widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60) {
            self.viewModel = viewModel
            self.backgroundColor = backgroundColor
            self.widthFraction = widthFraction
            self.innerRadiusFraction = innerRadiusFraction
//            self.amount = String(data.compactMap { $0.amountAsDouble }.reduce(0, +))
//            self.sliceData = data
        }
        
        private func getAmount(from values: [String]) -> String {
            let doubleValues: [Double] = values.compactMap { Double($0) }
            
            return String(doubleValues.compactMap { $0 }.reduce(0, +))
        }
        
        public var body: some View {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(self.backgroundColor)
                    ForEach(viewModel.slices, id: \.self) { slice in
                        pieSliceView(pieSliceData: slice)
                            .scaleEffect(self.tappedSlice?.name == slice.name ? 1.03 : 1)
                            .animation(Animation.spring())
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    Circle()
                        .fill(self.backgroundColor)
                        .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)
                        .onTapGesture {
//                            resetValues()
                        }
                    VStack {
                        Text(title)
                            .font(.title)
                            .foregroundColor(Color.gray)
                            .onTapGesture {
//                                resetValues()
                            }
                        Text("\(viewModel.maxAmount)")
                            .font(.title)
                            .foregroundColor(.black)
                            .onTapGesture {
//                                resetValues()
                            }
                    }
                }
            }
        }
        
        private func pieSliceView(pieSliceData: PieChart.Slice) -> some View {
            
            var midRadians: Double {
                return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
            }
            
            var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        Path { path in
                            let width: CGFloat = min(geometry.size.width, geometry.size.height)
                            let height = width
                            let center = CGPoint(x: width * 0.5, y: height * 0.5)
                            
                            path.move(to: center)
                            
                            // offset of 90 degrees because, in the SwiftUI coordinate system, the 0 degree starts at 3 o’clock instead of o’clock
                            path.addArc(
                                center: center,
                                radius: width * 0.5,
                                startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                                endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                                clockwise: false)
                            
                        }
                        .fill(colors.randomElement()!)
                        .onTapGesture {
                            //updateUI(pieSliceData)
                        }
                        
                        Text(pieSliceData.percent)
                            .position(
                                x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(midRadians)),
                                y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(midRadians))
                            )
                            .foregroundColor(Color.white)
                            .onTapGesture {
                                //updateUI(pieSliceData)
                            }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
            }
            
            return body
        }
        
//        private func updateUI(_ pieSliceData: PieChart.Slice) {
//            title = pieSliceData.name
//            amount = pieSliceData.amount
//
//            sliceData.forEach { type in
//                if pieSliceData.name == type.name {
//                    tappedSlice = type
//                }
//            }
//        }
//
//        private func resetValues() {
//            title = "Total"
//            tappedSlice = nil
//            amount = String(sliceData.compactMap { $0.amountAsDouble }.reduce(0, +))
//        }
    }
}
