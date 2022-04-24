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
        
        private let allPoints: [LineChart.Point]
        @Published private(set) var points: [LineChart.Point]
        var currentFilter: Filter = .max {
            didSet {
                filterDates(by: currentFilter)
            }
        }
        
        var maxAmount: Float {
            points.reduce(0) { $0 + $1.amount }
        }
        var largestAmount: Float {
            points.max(by: { $0.amount < $1.amount })?.amount ?? 0
        }
        var smallestAmount: Float {
            points.min(by: { $0.amount < $1.amount })?.amount ?? 0
        }
        var firstDate: Date? {
            points.first?.date
        }
        var latestDate: Date? {
            points.last?.date
        }
        
        public init(points: [LineChart.Point]) {
            self.allPoints = points.sorted { $0.date < $1.date }
            self.points = allPoints
        }
        
        func add(_ point: LineChart.Point) {
            var tempPoints = points
            tempPoints.append(point)
            points = tempPoints.sorted { $0.date < $1.date }
        }
        
        func remove(_ point: LineChart.Point) {
            guard let index = points.firstIndex(where: { $0.id == point.id }) else {
                return
            }
            points.remove(at: index)
        }
        
        func formatDate(_ date: Date?, format: String) -> String {
            guard let date = date else {
                return ""
            }
                
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = format
            
            return dateformatter.string(from: date)
        }
        
        private func filterDates(by filter: LineChart.ViewModel.Filter) {
            guard let latestDate = latestDate else {
                return
            }
            
            var amountOfDays = 0
            
            switch filter {
            case .week:
                amountOfDays = -7
            case .month:
                amountOfDays = -30
            case .year:
                amountOfDays = -365
            case .max:
                points = allPoints
                return
            }
            
            let filteredPoints = allPoints.filter { $0.date > latestDate.addOrSubtructDay(day: amountOfDays) }
            points = filteredPoints
        }
        
        private func addOrSubtructDay(day:Int) -> Date {
            return Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
          }
    }
}

extension LineChart.ViewModel {
    public enum Filter: CaseIterable {
        case week, month, year, max
        
        var name: String {
            switch self {
            case .week:
                return "Week"
            case .month:
                return "Month"
            case .year:
                return "Year"
            case .max:
                return "Max"
            }
        }
    }
}

private extension Date {
    func addOrSubtructDay(day:Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: self) ?? Date()
    }
}
