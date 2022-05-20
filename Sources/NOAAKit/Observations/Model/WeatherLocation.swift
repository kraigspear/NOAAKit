//
//  WeatherLocation.swift
//
//
//  Created by Kraig Spear on 6/28/21.
//

import CoreLocation
import Foundation

/// A location that has weather information
public struct WeatherLocation {
    /// The `coordinate` of the location containing weather
    public let coordinate: Coordinate
    /// Weather at this `WeatherLocation`
    public var weather: Weather?

    public init(coordinate: Coordinate) {
        self.coordinate = coordinate
    }

    public init(coordinate: Coordinate,
                weather: Weather) {
        self.coordinate = coordinate
        self.weather = weather
    }
}
