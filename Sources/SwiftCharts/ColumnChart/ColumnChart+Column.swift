//
//  BarChart+Data.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-27.
//

import Foundation
import SwiftUI

extension ColumnChart {
    public struct Column: Identifiable, Hashable {
        
        let name: String
        let amount: Float
        let additionalInfo: [AdditionalInfo]?
        let columnConfig: Config
        public let id = UUID()
        
        public init(name: String, amount: Float, additionalInfo: [AdditionalInfo]? = nil, columnConfig: Config = .init()) {
            self.amount = amount
            self.name = name
            self.additionalInfo = additionalInfo
            self.columnConfig = columnConfig
        }
    }
}

extension ColumnChart.Column {
    public struct Config: Hashable, DataConfig {
        let columnColor: Color
        let backgroundColor: Color
        let textColor: Color
        let titleFont: Font
        let textFont: Font
        
        public init(columnColor: Color = .column, backgroundColor: Color = .columnBackground, textColor: Color = .primaryText, titleFont: Font = .largeTitle, textFont: Font = .body) {
            self.columnColor = columnColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.textFont = textFont
        }
    }
}
