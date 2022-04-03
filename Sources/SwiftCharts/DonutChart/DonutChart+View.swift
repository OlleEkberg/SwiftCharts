//
//  DonutChart+View.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import SwiftUI


extension DonutChart {
    struct ChartView: View {
        
        let pie = PieChart.ChartView(viewModel: PieChart.ViewModel.init(slices: []))
        let fractionConfig = FractionConfig()
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    pie.pieChart(geometry.size)
                    Circle()
                        .fill(.yellow)
                        .frame(width: geometry.size.width * fractionConfig.innerRadiusFraction, height: geometry.size.width * fractionConfig.innerRadiusFraction)
                        .onTapGesture {
                            //                            resetValues()
                        }
                    VStack {
                        Text("title")
                            .font(.title)
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                //                                resetValues()
                            }
                        Text("viewModel.maxAmount")
                            .font(.title)
                            .foregroundColor(.black)
                            .onTapGesture {
                                //                                resetValues()
                            }
                    }
                }
            }
        }
    }
}
