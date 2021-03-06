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
        var currentFilter: Filter {
            didSet {
                if currentFilter == .max {
                    points = allPoints
                    
                    return
                }
                points = allPoints.filteredBy(currentFilter, latestDate: allPoints.last?.date)
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
        
        public init(points: [LineChart.Point], startingFilter: Filter = .month) {
            self.allPoints = points.sorted { $0.date < $1.date }
            self.currentFilter = startingFilter
            self.points = allPoints.filteredBy(startingFilter, latestDate: allPoints.last?.date)
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
                return 365 / 4
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
