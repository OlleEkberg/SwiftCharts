//
//  PieChart+ViewModel.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation
import SwiftUI

extension PieChart {
    public class ViewModel: ObservableObject, ChartViewModel {
        
        @Published private(set) var slices: [PieChart.Slice] = []
        var selecedSlice: PieChart.Slice? = nil
        var smallSlices: SmallPieSliceCollection? = nil
        var maxAmount: Float {
            slices.reduce(0) { $0 + $1.amount }
        }
        
        public init(slices: [PieChart.Slice]) {
            self.slices = createPieSlices(slices)
        }
        
        func add(_ slice: PieChart.Slice) {
            var tempSlices = slices
            tempSlices.append(slice)
            slices = createPieSlices(tempSlices)
        }
        
        func remove(_ slice: PieChart.Slice) {
            guard let index = slices.firstIndex(where: { $0.id == slice.id }) else {
                return
            }
            slices.remove(at: index)
        }
        
        func getPercent(_ slice: PieChart.Slice) -> Float {
            Float(slice.amount / maxAmount * 100)
        }
        
        private func createPieSlices(_ slices: [PieChart.Slice]) -> [PieChart.Slice] {
            let sum = slices.reduce(0) { $0 + $1.amount }
            var endDeg: Double = 0
            
            var tempSlices: [PieChart.Slice] = []
            var smallChartSlices = SmallPieSliceCollection(slices: [])
            
            slices.forEach { slice in
                let degrees: Double = Double(slice.amount * 360 / sum)
                var tempSlice = slice
                tempSlice.startAngle = Angle(degrees: endDeg)
                tempSlice.endAngle = Angle(degrees: endDeg + degrees)
                if Float(slice.amount / sum * 100) <= 2 {
                    smallChartSlices.slices.append(tempSlice)
                    smallChartSlices.sum = sum
                    smallSlices = smallChartSlices
                } else {
                    tempSlices.append(tempSlice)
                }
                
                endDeg += degrees
            }
            
            if let smallSlices = smallSlices {
                var slice = PieChart.Slice(name: "Other", amount: smallSlices.slices.reduce(0) { $0 + $1.amount })
                slice.startAngle = Angle(degrees: 360 - endDeg)
                slice.endAngle = smallSlices.endAngle
                
                tempSlices.append(slice)
            }
            
            return tempSlices
        }
    }
}

extension PieChart.ViewModel {
    struct SmallPieSliceCollection {
        var slices: [PieChart.Slice]
        var sum: Float = 0
        var startAngle: Angle {
            Angle(degrees: 0)
        }
        var endAngle: Angle {
            let amount = slices.reduce(0) { $0 + $1.amount }
            let degrees: Double = Double(amount * 360 / sum)
            return Angle(degrees: 0 + degrees)
        }
    }
}
