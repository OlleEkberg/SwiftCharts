//
//  Color+Random.swift
//  
//
//  Created by Olle  Ekberg on 2022-04-04.
//

import SwiftUI

public extension Color {
    static let random: Color = Color(red: Double.random(in: 0.00...1.00), green: Double.random(in: 0.00...1.00), blue: Double.random(in: 0.00...1.00))
}
