//
//  DonutChart+FractionConfig.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import SwiftUI

extension DonutChart {
    public struct FractionConfig {
        let widthFraction: CGFloat
        let innerRadiusFraction: CGFloat
        
        init(widthFraction: CGFloat = 0.75, innerRadiusFraction: CGFloat = 0.60) {
            self.widthFraction = widthFraction
            self.innerRadiusFraction = innerRadiusFraction
        }
    }
}
