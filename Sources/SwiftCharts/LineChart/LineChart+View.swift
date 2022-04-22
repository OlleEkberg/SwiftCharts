//
//  LineChart+View.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-22.
//

import SwiftUI

extension LineChart {
    struct ChartView: View {
        
        @ObservedObject private var viewModel: LineChart.ViewModel
        var body: some View {
            GeometryReader { geometry in
                ForEach(viewModel.points, id: \.self) { point in
                    Text(point.name)
                }
            }
        }
    }
}

