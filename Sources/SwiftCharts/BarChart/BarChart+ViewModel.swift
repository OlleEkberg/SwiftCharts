//
//  BarChart+ViewModel.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-27.
//

import Foundation
import SwiftUI

extension BarChart {
    public class ViewModel: ObservableObject, ChartViewModel {
        
        public enum SortMethod: CaseIterable {
            case smallFirst,
                 largeFirst,
                 alpabetical,
                 original
            
            var name: String {
                switch self {
                case .smallFirst:
                    return Translations.sortSmallestFirst
                case .largeFirst:
                    return Translations.sortLargestFirst
                case .alpabetical:
                    return Translations.sortAlphabetical
                case .original:
                    return Translations.sortOriginal
                }
            }
        }
        
        @Published private(set) var data: [BarChart.Bar]
        private(set) var currentSortMethod: SortMethod
        private(set) var selectedData: BarChart.Bar? = nil
        private(set) var previousSelectedIndex: Int? = nil
        private var originalSortedData: [BarChart.Bar]
        var amountOfData: Int {
            data.count
        }
        var maxAmount: Float {
            data.reduce(.zero) { $0 + $1.amount }
        }
        
        public init(data: [BarChart.Bar], sortMethod: SortMethod = .original) {
            self.data = data
            self.currentSortMethod = sortMethod
            
            self.originalSortedData = data
            if sortMethod != .original {
                sort(by: sortMethod)
            }
        }
        
        func add(_ bar: BarChart.Bar) {
            data.append(bar)
        }
        
        func remove(_ bar: BarChart.Bar) {
            guard let index = data.firstIndex(where: { $0.id == bar.id }) else {
                return
            }
            data.remove(at: index)
        }
        
        func sort(by method: SortMethod) {
            switch method {
            case .smallFirst:
                data = data.sorted { $0.amount < $1.amount }
            case .largeFirst:
                data = data.sorted { $0.amount > $1.amount }
            case .alpabetical:
                data = data.sorted { $0.name < $1.name }
            case .original:
                data = originalSortedData
            }
            
            currentSortMethod = method
        }
        
        func didSelect(data selectedData: BarChart.Bar) {
            guard let currentIndex = data.firstIndex(where: { $0 == selectedData }) else {
                return
            }
            data.move(from: currentIndex, to: data.startIndex)
            previousSelectedIndex = currentIndex
            self.selectedData = selectedData
        }
        
        func didReset(data selectedData: BarChart.Bar) {
            if self.selectedData != nil {
                data.move(from: 0, to: previousSelectedIndex!)
                resetSelectedData()
                
                return
            }
            guard let pressedBarIndex = data.firstIndex(where: { $0 == selectedData }) else {
                return
            }
            data.move(from: pressedBarIndex, to: previousSelectedIndex!)
            resetSelectedData()
        }
        
        private func resetSelectedData() {
            previousSelectedIndex = nil
            selectedData = nil
        }
    }
}

private extension Array where Element: Equatable {
    mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) { self.move(from: oldIndex, to: newIndex) }
    }
}

private extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
