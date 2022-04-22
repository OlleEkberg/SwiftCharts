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
                ForEach(viewModel.points, id: \.self) { point in
                    Text(point.name)
                }
            }
        }
    }
}

