//
//  BarChart+SortConfig.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-02.
//

import Foundation
import SwiftUI

extension BarChart {
    public struct SortConfig {
        let shouldShow: Bool
        let titleFont: Font
        let titleColor: Color
        let titleBackgroundColor: Color
        let methodTextColor: Color
        let methodFont: Font
        let imageColor: Color
        let image: Image
        
        public init(shouldShow: Bool = true, titleFont: Font = .largeTitle, titleColor: Color = .primaryText, titleBackgroundColor: Color = .primaryBackground, methodTextColor: Color = .buttonText, methodFont: Font = .body, imageColor: Color = .primaryText, image: Image = Image(systemName: "slider.horizontal.3")) {
            self.shouldShow = shouldShow
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.titleBackgroundColor = titleBackgroundColor
            self.methodTextColor = methodTextColor
            self.methodFont = methodFont
            self.imageColor = imageColor
            self.image = image
        }
    }
}
