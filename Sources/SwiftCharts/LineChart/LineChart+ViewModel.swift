//
//  LineChart+ViewModel.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-22.
//

import Foundation
import SwiftUI

extension LineChart {
    public class ViewModel: ObservableObject, ChartViewModel {
        
        @Published private(set) var points: [LineChart.Point]
        
        var maxAmount: Float {
            points.reduce(0) { $0 + $1.amount }
        }
        
        public init(points: [LineChart.Point]) {
            self.points = points.sorted { $0.amount < $1.amount }
        }
        
        func add(_ point: LineChart.Point) {
            var tempPoints = points
            tempPoints.append(point)
            points = tempPoints.sorted { $0.amount < $1.amount }
        }
        
        func remove(_ point: LineChart.Point) {
            guard let index = points.firstIndex(where: { $0.date == point.date }) else {
                return
            }
            points.remove(at: index)
        }
    }
}
