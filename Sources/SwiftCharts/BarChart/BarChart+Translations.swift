//
//  BarChart+Translations.swift
//  Carbon Positive
//
//  Created by Olle  Ekberg on 2022-03-29.
//

import Foundation
import SwiftUI

extension BarChart {
     enum Translations {
         static let sortBy = NSLocalizedString("SWIFTCHARTS.BARCHART.SORT.BY", bundle: .module, comment: "")
         static let sortSmallestFirst = NSLocalizedString("SWIFTCHARTS.BARCHART.SORT.SMALLEST.FIRST", bundle: .module, comment: "")
         static let sortLargestFirst = NSLocalizedString("SWIFTCHARTS.BARCHART.SORT.LARGEST.FIRST", bundle: .module, comment: "")
         static let sortOriginal = NSLocalizedString("SWIFTCHARTS.BARCHART.SORT.ORIGINAL", bundle: .module, comment: "")
         static let sortAlphabetical = NSLocalizedString("SWIFTCHARTS.BARCHART.SORT.ALPHABETICAL", bundle: .module, comment: "")
         static let amount = NSLocalizedString("SWIFTCHARTS.BARCHART.AMOUNT", bundle: .module, comment: "")
         static let percent = NSLocalizedString("SWIFTCHARTS.BARCHART.PERCENT", bundle: .module, comment: "")
    }
}
