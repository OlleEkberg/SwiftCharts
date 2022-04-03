//
//  File.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-03.
//

import Foundation

protocol ChartViewModel {
    associatedtype Element
    var maxAmount: Float { get }
    func add(_ data: Element)
    func remove(_ data: Element)
}
