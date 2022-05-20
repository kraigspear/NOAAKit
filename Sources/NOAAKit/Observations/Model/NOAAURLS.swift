//
//  NOAAURLS.swift
//
//  Created by Kraig Spear on 7/17/21.
//

import Foundation

/// Model containing URLS for various NOAA API calls
/// https://api.weather.gov/points/42.7892,-85.5167
struct NOAAURLS: Decodable {
    /// URL that returns Observation Stations
    /// Example: https://api.weather.gov/gridpoints/GRR/46,38/stations
    let observationStations: String
}
