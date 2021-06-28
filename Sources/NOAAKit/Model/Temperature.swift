//
//  Temperature.swift
//  
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

/// Alias for the type that represents a temperature
public typealias TemperatureDegrees = Float

/// Temperature at a given time
public struct Temperature: Codable {
    /// The actual air temperature
    public let actual: TemperatureDegrees
    /// What it feels like
    public let feelsLike: TemperatureDegrees
}
