//
//  NOAACurrentConditionsModel.swift
//  
//
//  Created by Kraig Spear on 6/20/21.
//

import Foundation

enum NOAAParseError: Error {
    case parseError(field: String)
}

struct NOAAForecast: Decodable {

    enum CodingKeys: String, CodingKey {
        case currentObservation = "currentobservation"
    }

    let currentObservation: CurrentObservation
}

// MARK: - Currentobservation
struct CurrentObservation: Codable {
    let id, name, elev, latitude: String
    let longitude, date, temp, dewp: String
    let relh, winds, windd, gust: String
    let weather, weatherimage, visibility, altimeter: String
    let slp, timezone, state, windChill: String

    enum CodingKeys: String, CodingKey {
        case id, name, elev, latitude, longitude
        case date = "Date"
        case temp = "Temp"
        case dewp = "Dewp"
        case relh = "Relh"
        case winds = "Winds"
        case windd = "Windd"
        case gust = "Gust"
        case weather = "Weather"
        case weatherimage = "Weatherimage"
        case visibility = "Visibility"
        case altimeter = "Altimeter"
        case slp = "SLP"
        case timezone, state
        case windChill = "WindChill"
    }


    func toCurrent() throws -> Current {
        let temperature = try self.temperature
        return Current(temperature: temperature)
    }

    private var temperature: Temperature {
        get throws {
            try Temperature(actual: actual, feelsLike: feelsLike)
        }
    }

    private var actual: TemperatureDegrees {
        get throws {
            if let temperature = TemperatureDegrees(self.temp) {
                return temperature
            }
            throw NOAAParseError.parseError(field: "temp")
        }
    }

    private var feelsLike: TemperatureDegrees {
        get throws {
            if let windChill = TemperatureDegrees(windChill) {
                // It is expected that wind chill will not convert to a temperature.
                // It can contain values such as NA
                return windChill
            }
            return try self.actual
        }
    }
}
