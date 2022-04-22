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
                    createPath(geometry.size.width)
                        .stroke(.black, lineWidth: 8)
                }
            }
        }
        
        func createPath(_ width: CGFloat) -> Path {
            guard viewModel.points.count > 1,
                  let firstPoint = viewModel.points.first else {
                return Path()
            }
            
            var offsetX: Int = Int(width/CGFloat(viewModel.points.count))
            var path = Path()
            path.move(to: .init(x: offsetX, y: Int(firstPoint.amount)))
            
            for point in viewModel.points {
                offsetX += Int(width/CGFloat(viewModel.points.count))
                path.addLine(to: .init(x: offsetX, y: Int(point.amount)))
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

