//
//  PieChart+Slice.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import SwiftUI

extension PieChart {
    public struct Slice: Identifiable, Hashable {
        let startAngle: Angle
        let endAngle: Angle
        let name: String
        let amount: Float
        let percent: String
        let additionalInfo: [AdditionalInfo]?
        let sliceConfig: Config
        public let id = UUID()
        
        public init(startAngel: Angle, endAngle: Angle, name: String, amount: Float, percent: String, additionalInfo: [AdditionalInfo]? = nil, sliceConfig: Config = .init()) {
            self.startAngle = startAngel
            self.endAngle = endAngle
            self.name = name
            self.amount = amount
            self.percent = percent
            self.additionalInfo = additionalInfo
            self.sliceConfig = sliceConfig
        }
    }
}

extension PieChart.Slice {
    public struct Config: Hashable, DataConfig {
        let sliceColor: Color
        let textColor: Color
        let titleFont: Font
        let textFont: Font
        
        public init(barColor: Color = .bar, textColor: Color = .primaryText, titleFont: Font = .largeTitle, textFont: Font = .body) {
            self.sliceColor = barColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.textFont = textFont
        }
    }
}
