//
//  Current.swift
//  
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

/// The current weather conditions
public struct CurrentConditions: Codable {
    /// Date of for the conditions
    public let date: Date
    /// The current temperature
    public let temperature: Temperature
}
