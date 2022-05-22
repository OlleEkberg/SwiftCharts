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
        var currentFilter: Filter = .month {
            didSet {
                filterDates(by: currentFilter)
            }
        }
        
        var maxAmount: Float {
            allPoints.reduce(0) { $0 + $1.amount }
        }
        var largestAmount: Float {
            allPoints.max(by: { $0.amount < $1.amount })?.amount ?? 0
        }
        var smallestAmount: Float {
            allPoints.min(by: { $0.amount < $1.amount })?.amount ?? 0
        }
        var firstDate: Date? {
            allPoints.first?.date
        }
        var latestDate: Date? {
            allPoints.last?.date
        }
        
        public init(points: [LineChart.Point]) {
            self.allPoints = points.sorted { $0.date < $1.date }
            self.points = allPoints.filteredBy(.month, latestDate: allPoints.last?.date)
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
            
            if case .max = filter {
                points = allPoints
                return
            }
            
            let filteredPoints = allPoints.filter { $0.date > latestDate.addOrSubtructDay(days: -filter.days) }
            points = filteredPoints
        }
        
        private func addOrSubtructDay(day: Int) -> Date {
            return Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
          }
    }
}

extension LineChart.ViewModel {
    public enum Filter: CaseIterable {
        case day, week, month, threeMonths, sixMonths, oneYear, twoYears, threeYears, max, custom
        
        var name: String {
            switch self {
            case .day:
                return Translations.filterDay
            case .week:
                return Translations.filterWeek
            case .month:
                return Translations.filterMonth
            case .threeMonths:
                return Translations.filterThreeMonths
            case .sixMonths:
                return Translations.filterSixMonths
            case .oneYear:
                return Translations.filterYear
            case .twoYears:
                return Translations.filterTwoYears
            case .threeYears:
                return Translations.filterThreeYears
            case .max:
                return Translations.filterMax
            case .custom:
                return ""
            }
        }
        
        var days: Int {
            switch self {
            case .day:
                return 1
            case .week:
                return 7
            case .month:
                return 30
            case .threeMonths:
                return 32
            case .sixMonths:
                return 183
            case .oneYear:
                return 365
            case .twoYears:
                return 365 * 2
            case .threeYears:
                return 365 * 3
            case .max, .custom:
                return 0
            }
        }
    }
}

private extension Date {
    func addOrSubtructDay(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? Date()
    }
}

private extension Array where Element == LineChart.Point {
    func filteredBy(_ filter: LineChart.ViewModel.Filter, latestDate: Date?) -> [Element] {
        guard let latestDate = latestDate else {
            return []
        }

        return self.filter { $0.date > latestDate.addOrSubtructDay(days: -filter.days) }
    }
}
