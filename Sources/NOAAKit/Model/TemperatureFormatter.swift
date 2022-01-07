//
//  TemperatureFormatter.swift
//  
//
//  Created by Kraig Spear on 7/14/21.
//

import Foundation

/// Formats a temperature
public protocol TemperatureFormatting {
    /**
     Formats a temperature based on the system it's running on
     - parameter temperature: Temperature to format
     - returns: A string representation of the temperature
     */
    func format(_ temperature: TemperatureDegrees) -> String
}

/**
 Formats a temperature based on the system it's running on
 */
public final class TemperatureFormatter: TemperatureFormatting {

    /// Should the temperature be formatted with metric or standard
    private let usesMetricSystem: Bool

    /**
     **/
    public init(usesMetricSystem: Bool = NSLocale.current.usesMetricSystem) {
        self.usesMetricSystem = usesMetricSystem
    }

    public func format(_ temperature: TemperatureDegrees) -> String {
        let temperature = Int(convertTemperature(temperature))
        return "\(temperature)\(suffix)"
    }

    private var suffix: String {
        usesMetricSystem ? "℃" : "℉"
    }

    private func convertTemperature(_ temperature: TemperatureDegrees) -> TemperatureDegrees {
        guard usesMetricSystem else {
            return temperature
        }

        let convertedMeasurement = Measurement(value: temperature, unit: UnitTemperature.fahrenheit).converted(to: .celsius)

        return convertedMeasurement.value
    }
}
