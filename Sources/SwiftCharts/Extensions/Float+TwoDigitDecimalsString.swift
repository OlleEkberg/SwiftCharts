//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-23.
//

import Foundation

extension Float {
    func twoDigitDecimalString() -> String {
        String(format: "%.2f", self)
    }
}
