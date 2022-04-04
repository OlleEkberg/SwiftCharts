//
//  PieChart+Slice.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import SwiftUI

extension PieChart {
    public struct Slice: Identifiable, Hashable {
        var startAngle: Angle? = nil
        var endAngle: Angle? = nil
        let name: String
        let amount: Float
        let additionalInfo: [AdditionalInfo]?
        let config: Config
        public let id = UUID()
        
        public init(name: String, amount: Float, additionalInfo: [AdditionalInfo]? = nil, config: Config = .init()) {
            self.name = name
            self.amount = amount
            self.additionalInfo = additionalInfo
            self.config = config
        }
    }
}

extension PieChart.Slice {
    public struct Config: Hashable, DataConfig {
        let sliceColor: Color
        let textColor: Color
        let titleFont: Font
        let textFont: Font
        
        public init(sliceColor: Color = .random, textColor: Color = .primaryText, titleFont: Font = .largeTitle, textFont: Font = .body) {
            self.sliceColor = sliceColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.textFont = textFont
        }
    }
}
