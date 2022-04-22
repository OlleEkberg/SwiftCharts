//
//  LineChart+Point.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-22.
//

import Foundation

extension LineChart {
    public struct Point: Hashable {
        let name: String
        let amount: Float
        let date: Date
        let additionalData: [AdditionalData]?
        public let id = UUID()
        
        public init(name: String, amount: Float, date: Date, additionalData: [AdditionalData]? = nil) {
            self.name = name
            self.amount = amount
            self.date = date
            self.additionalData = additionalData
        }
    }
}

extension LineChart.Point {
    public struct AdditionalData: Hashable {
        let name: String
        let value: String
    }
}
