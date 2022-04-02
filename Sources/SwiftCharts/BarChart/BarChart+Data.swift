//
//  BarChart+Data.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-27.
//

import Foundation
import SwiftUI

extension BarChart {
    public struct Data: Identifiable, Hashable {
        
        let name: String
        let amount: Float
        let additionalInfo: [AdditionalInfo]?
        let barConfig: Config
        public let id = UUID()
        
        public init(name: String, amount: Float, additionalInfo: [AdditionalInfo]? = nil, barConfig: Config = .init()) {
            self.amount = amount
            self.name = name
            self.additionalInfo = additionalInfo
            self.barConfig = barConfig
        }
    }
}

extension BarChart.Data {
    public struct AdditionalInfo: Hashable {
        let name: String
        let value: String
    }
    
    public struct Config: Hashable {
        let barColor: Color
        let backgroundColor: Color
        let textColor: Color
        let titleFont: Font
        let textFont: Font
        
        public init(barColor: Color = .bar, backgroundColor: Color = .barBackground, textColor: Color = .primaryText, titleFont: Font = .largeTitle, textFont: Font = .body) {
            self.barColor = barColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.textFont = textFont
        }
    }
}
