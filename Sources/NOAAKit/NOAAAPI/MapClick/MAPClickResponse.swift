//
//  MAPClickResponse.swift
//  
//
//  Created by Kraig Spear on 6/20/21.
//

import Foundation

// MARK: - CurrentObservation

/// Model Class from

/// Models coming from the NOAA API
/// These models will be transformed into a more coherent data model
struct MAPClickResponse {

    enum ParseError: Error {
        case parseError(field: String)
    }

    struct Root: Decodable {

        enum CodingKeys: String, CodingKey {
            case currentObservation = "currentobservation"
        }

        let currentObservation: CurrentObservation
    }

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
    }
}


