//
//  Temperature.swift
//  
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

/// Alias for the type that represents a temperature
public typealias TemperatureDegrees = Int

/// Temperature at a given time
public struct Temperature: Codable {
    /// The actual air temperature
    public let actual: TemperatureDegrees
    /// What it feels like
    public let feelsLike: TemperatureDegrees

    public init(actual: TemperatureDegrees,
                feelsLike: TemperatureDegrees) {
        self.actual = actual
        self.feelsLike = feelsLike
    }
}

public extension TemperatureDegrees {
    var formatted: String {
        TemperatureFormatter().format(self)
    }
}
