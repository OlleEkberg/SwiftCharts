//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-07.
//

import Foundation
extension PieChart {
    public enum ChartType {
        case pie,
             donut(DonutChart.FractionConfig = .init())
    }
}
