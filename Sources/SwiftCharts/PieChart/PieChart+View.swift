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
        @State private var selectedSlice: PieChart.Slice? = nil
//        @State private var tappedSlice: PieChart.Slice? = nil {
//            didSet {
//                self.previouslyTappedSlice = oldValue
//            }
//        }
//        @State private var previouslyTappedSlice: PieChart.Slice? = nil
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
                    .padding()
            }
        }
        
        func pieChart(_ size: CGSize) -> some View {
            var body: some View {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(self.backgroundColor)
                    ForEach(viewModel.slices, id: \.self) { slice in
                        sliceView(slice)
                            .scaleEffect(sliceScale(slice))
                            .blur(radius: sliceBlur(slice))
                            .animation(Animation.spring())
                    }
                    .frame(width: size.width, height: size.width)
                }
            }
            return body
        }
        
        private func sliceView(_ slice: PieChart.Slice) -> some View {
            
            var body: some View {
                GeometryReader { geometry in
                    if let startAngle = slice.startAngle, let endAngle = slice.endAngle {
                        let midRadians = Double.pi / 2.0 - (startAngle + endAngle).radians / 2.0
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
                                    startAngle: Angle(degrees: -90.0) + startAngle,
                                    endAngle: Angle(degrees: -90.0) + endAngle,
                                    clockwise: false)
                                
                            }
                            .fill(colors.randomElement()!)
                            .onTapGesture {
                                selectSlice(slice)
                            }
                            
                            Text("piece.percent")
                                .position(
                                    x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(midRadians)),
                                    y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(midRadians))
                                )
                                .foregroundColor(Color.white)
                                .onTapGesture {
                                    selectSlice(slice)
                                }
                        }
                    }
                    
                }
                .aspectRatio(1, contentMode: .fit)
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
        
//        private func updateUI(_ slice: PieChart.piece) {
//            title = slice.name
//            amount = slice.amount
//
//            slices.forEach { current in
//                if slice.id == current.id {
//                    tappedpiece = type
//                }
//            }
//        }
//
//        private func resetValues() {
//            title = "Total"
//            tappedpiece = nil
//            amount = String(pieceData.compactMap { $0.amountAsDouble }.reduce(0, +))
//        }
        
        
    }
}
