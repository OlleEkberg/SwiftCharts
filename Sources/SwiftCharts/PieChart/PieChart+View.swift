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
        }
        
        public var body: some View {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(self.backgroundColor)
                    ForEach(viewModel.slices, id: \.self) { slice in
                        piepieceView(slice)
                            .scaleEffect(self.tappedSlice?.name == slice.name ? 1.03 : 1)
                            .animation(Animation.spring())
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    Circle()
                        .fill(self.backgroundColor)
//                        .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)
                        .frame(width: 2, height: 2)
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
        
        private func piepieceView(_ slice: PieChart.Slice) -> some View {
            
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
                                //updateUI(piepieceData)
                            }
                            
                            Text("piece.percent")
                                .position(
                                    x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(midRadians)),
                                    y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(midRadians))
                                )
                                .foregroundColor(Color.white)
                                .onTapGesture {
                                    //updateUI(piepieceData)
                                }
                        }
                    }
                    
                }
                .aspectRatio(1, contentMode: .fit)
            }
            
            return body
        }
        
//        private func updateUI(_ piepieceData: PieChart.piece) {
//            title = piepieceData.name
//            amount = piepieceData.amount
//
//            pieceData.forEach { type in
//                if piepieceData.name == type.name {
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
