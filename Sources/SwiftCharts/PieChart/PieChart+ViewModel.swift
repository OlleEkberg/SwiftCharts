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
        var selecedSlice: PieChart.Slice? = nil
        var maxAmount: Float {
            slices.reduce(0) { $0 + $1.amount }
        }
        
        public init(slices: [PieChart.Slice]) {
            self.slices = createPiepieces(slices)
        }
        
        func add(_ slice: PieChart.Slice) {
            var tempSlices = slices
            tempSlices.append(slice)
            slices = createPiepieces(tempSlices)
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
        
        private func createPiepieces(_ slices: [PieChart.Slice]) -> [PieChart.Slice] {
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
            
            print("Temp Slices: \(tempSlices)")
            return tempSlices
        }
    }
}
