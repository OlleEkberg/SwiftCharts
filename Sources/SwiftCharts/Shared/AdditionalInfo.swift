//
//  AdditionalInfo.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation

public struct AdditionalInfo: Hashable {
    let name: String
    let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}
