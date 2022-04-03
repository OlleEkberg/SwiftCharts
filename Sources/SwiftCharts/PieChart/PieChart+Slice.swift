//
//  PieChart+Piece.swift
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
        let sliceConfig: Config
        public let id = UUID()
        
        public init(name: String, amount: Float, additionalInfo: [AdditionalInfo]? = nil, sliceConfig: Config = .init()) {
            self.name = name
            self.amount = amount
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
        
        public init(sliceColor: Color = .bar, textColor: Color = .primaryText, titleFont: Font = .largeTitle, textFont: Font = .body) {
            self.sliceColor = sliceColor
            self.textColor = textColor
            self.titleFont = titleFont
            self.textFont = textFont
        }
    }
}
