//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-23.
//

import Foundation
import SwiftUI

extension LineChart {
    public struct Config {
        let lineWidth: CGFloat
        let lineColor: Color
        let backgroundColor: Color
        let textColor: Color
        let dividerColor: Color
        let dateFormat: String
        
        public init(lineWidth: CGFloat = 2, lineColor: Color = .blue, backgroundColor: Color = .white, textColor: Color = .black, dividerColor: Color = .gray, dateFormat: String = "dd-MM-YYYY") {
            self.lineWidth = lineWidth
            self.lineColor = lineColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.dividerColor = dividerColor
            self.dateFormat = dateFormat
        }
    }
}
