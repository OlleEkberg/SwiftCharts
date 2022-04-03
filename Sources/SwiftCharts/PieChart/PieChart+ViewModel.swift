//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation
import SwiftUI

extension PieChart {
    public class ViewModel: ObservableObject, ChartViewModel {
        
        @Published private(set) var slices: [PieChart.Slice] = []
        var maxAmount: Float {
            slices.reduce(0) { $0 + $1.amount }
        }
        
        public init(slices: [PieChart.Slice]) {
            self.slices = createPieSlices(slices)
        }
        
        func add(_ slice: PieChart.Slice) {
            slices.append(slice)
        }
        
        func remove(_ slice: PieChart.Slice) {
            guard let index = slices.firstIndex(where: { $0.id == slice.id }) else {
                return
            }
            slices.remove(at: index)
        }
        
        private func createPieSlices(_ slices: [PieChart.Slice]) -> [PieChart.Slice] {
            let sum = slices.reduce(0) { $0 + $1.amount }
            var endDeg: Double = 0
            
            var tempSlices: [PieChart.Slice] = []
            
            slices.forEach { slice in
                let degrees: Double = Double(slice.amount * 360 / sum)
                var tempSlice = slice
                tempSlice.startAngle = Angle(degrees: endDeg)
                tempSlice.endAngle = Angle(degrees: endDeg + degrees)
                tempSlices.append(tempSlice)
                
                endDeg += degrees
            }
            
            return tempSlices
        }
    }
}
