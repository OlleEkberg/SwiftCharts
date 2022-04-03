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
        
        @Published private(set) var slices: [PieChart.Slice]
        var maxAmount: Float {
            slices.reduce(0) { $0 + $1.amount }
        }
        
        public init(slices: [PieChart.Slice]) {
            self.slices = slices
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
    }
}
