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
        
        let colors: [Color] = [.red, .blue, .green, .yellow]
        
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
                            .frame(width: size.width * 0.95, height: size.width * 0.95, alignment: .center)
                    }
                    
                    if let selectedSlice = selectedSlice {
                        infoView(selectedSlice)
                            .onTapGesture {
                                selectedSlice = nil
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
                        ZStack(alignment: .center) {
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
                            .fill(colors.randomElement()!)
                            .onTapGesture {
                                selectSlice(slice)
                            }
                            if selectedSlice == nil {
                                let percent = String(format: "%.2f", viewModel.getPercent(slice))
                                Text("\(percent)%")
                                    .position(
                                        x: geometry.size.width * smallMultiplier * CGFloat(mediumMultiplier + smallMultiplier * cos(midRadians)),
                                        y: geometry.size.height * smallMultiplier * CGFloat(mediumMultiplier - smallMultiplier * sin(midRadians))
                                    )
                                    .foregroundColor(Color.white)
                                    .onTapGesture {
                                        selectSlice(slice)
                                    }
                            }
                        }
                    }
                    
                }
//                .aspectRatio(1, contentMode: .fit)
            }
            
            return body
        }
        
        private func infoView(_ slice: PieChart.Slice) -> some View {
            var body: some View {
                VStack(alignment: .topLeading) {
                    Text(slice.name)
                    Text("\(slice.amount)")
                    let percent = String(format: "%.2f", viewModel.getPercent(slice))
                    Text("\(percent)%")
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
        
        
        //MARK: Constants
        let smallMultiplier = 0.5
        let mediumMultiplier = 1.0
        let bigMultiplier = 2.0
        let angleDegrees = 90.0
        let ninetyFivePercent = 95.0
    }
}
