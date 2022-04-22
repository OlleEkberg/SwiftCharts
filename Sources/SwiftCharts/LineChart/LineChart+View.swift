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
        
        public init(viewModel: LineChart.ViewModel) {
            self.viewModel = viewModel
        }
        
        public var body: some View {
            GeometryReader { geometry in
                VStack {
                    createPath(geometry.size.width, height: geometry.size.height)
                        .stroke(.black, lineWidth: 4)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                .background(Color.white)
                .padding()
            }
        }
        
        func createPath(_ width: CGFloat, height: CGFloat) -> Path {
            guard viewModel.points.count > 1,
                  let firstPoint = viewModel.points.first,
                  let largestAmount = viewModel.largestAmount else {
                return Path()
            }
            
            var offsetY: Int {
                if CGFloat(largestAmount) > height {
                    return Int(height / CGFloat(largestAmount))
                } else {
                    return 1
                }
            }
            
            var offsetX: Int = Int(width/CGFloat(viewModel.points.count))
            var path = Path()
            path.move(to: .init(x: 0, y: Int(firstPoint.amount)))
            
            for point in viewModel.points {
                offsetX += Int(width/CGFloat(viewModel.points.count))
                let y = Int(Int(point.amount) * offsetY)
                print("line: \(offsetX) - \(offsetY)")
                path.addLine(to: .init(x: offsetX, y: y))
            }
            
            return path
        }
        
        func lineChartView() -> some View {
            
            var body: some View {
                if let firstDate = viewModel.points.first?.date,
                      let lastDate = viewModel.points.last?.date,
                      let maxHeight = viewModel.largestAmount {
                    let dates = [firstDate...lastDate]
                    let height = [0...(maxHeight * 0.2)]
                    return EmptyView()
                } else {
                    return EmptyView()
                }
            }
            
            return body
        }
    }
}

