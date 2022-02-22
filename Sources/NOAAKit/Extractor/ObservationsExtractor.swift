//
//  CurrentConditionExtractor.swift
//  File
//
//  Created by Kraig Spear on 7/25/21.
//

import Foundation
import SpearFoundation
import SwiftUI

enum PropertyField: String {
    case timestamp
    case textDescription
    case windDirection
    case windSpeed
    case windGust
    case barometricPressure
    enum Temperature: String {
        case temperature
        case windChill
        case heatIndex
        case dewpoint
        var required: Bool {
            switch self {
            case .temperature, .dewpoint:
                return true
            default:
                return false
            }
        }
    }

    var required: Bool {
        switch self {
        case .windGust:
            return false
        default:
            return true
        }
    }
}

/**
 Extract out current condition from JSON
 */
struct ObservationsExtractor {
    private let observationStationURL: URL
    private let log = LogContext.observationsExtractor.logger

    init(observationStationURL: URL) {
        self.observationStationURL = observationStationURL
    }

    func extract() async throws -> Observation {

        let log = self.log

        func fetchObservationJSON() async throws -> JSON {

            func observationRequest() async throws -> URLRequest {

                func fetchStationIdentifier() async throws -> String {
                    let stationIdentifierElement = "stationIdentifier"
                    let featuresElement = "features"
                    let propertyElement = "properties"

                    var stationRequest = URLRequest(url: observationStationURL)
                    stationRequest.addStandardHeaders()
                    let stationJSON = try await stationRequest.fetchJSON()

                    guard let features = stationJSON[featuresElement] as? [JSON] else {
                        throw FetchError.parseFailed(field: featuresElement)
                    }

                    if let firstFeature = features.first {
                        if let properties = firstFeature[propertyElement] as? JSON {
                            if let stationIdentifier = properties[stationIdentifierElement] as? String {
                                return stationIdentifier
                            }
                        }
                    }

                    throw FetchError.stationIdentifierNotFound
                }

                let stationIdentifier = try await fetchStationIdentifier()
                let observationURL = URL(string: "https://api.weather.gov/stations/\(stationIdentifier)/observations/latest")!
                log.debug("observationURL: \(observationURL)")
                var observationRequest = URLRequest(url: observationURL)
                observationRequest.addStandardHeaders()
                return observationRequest
            }

            let request = try await observationRequest()
            log.debug("Fetching Observation data")
            let json = try await URLSession.shared.loadJSON(from: request)
            log.debug("Observation data fetched")
            return json
        }

        let json = try await fetchObservationJSON()

        let propertyNode = try json.json("properties")

        var temperature: TemperatureDegrees {
            get throws {
                if let temperature = try propertyNode.extractTemperatureNamed(.temperature) {
                    return temperature
                } else {
                    assertionFailure("temperature is required")
                    throw ExtractError.nilFound(fieldName: "temperature")
                }
            }
        }

        var timeStamp: Date {
            get throws {
                let fieldName = "timestamp"
                let timeStampStr = try propertyNode.string(PropertyField.timestamp.rawValue)
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let date = dateformatter.date(from: timeStampStr) {
                    return date
                }
                throw ExtractError.convertType(fieldName: fieldName)
            }
        }

        var windChill: TemperatureDegrees? {
            get throws {
                try propertyNode.extractTemperatureNamed(.windChill)
            }
        }

        var heatIndex: TemperatureDegrees? {
            get throws {
                try propertyNode.extractTemperatureNamed(.heatIndex)
            }
        }

        var wind: Wind {
            get {

                log.debug("Extract wind")

                // I've seen issues in the past where we might not get legit value for wind, so giving
                // the best defaults if any values are missing.

                // The force unwrapping will not happen if default values are provided and the field
                // is not marked as required.
                // If it does then it's logic errors that must be fixed.

                let direction: Int
                let speed: Float
                let gust: Float?

                do {
                    log.debug("WindDirection")
                    direction = try extractIntValue(.windDirection)
                } catch {
                    log.warning("Wind direction missing: \(error.localizedDescription)")
                    direction = 0
                }

                do {
                    log.debug("WindSpeed")
                    speed = try extractFloatValue(.windSpeed)
                } catch {
                    log.warning("Wind speed missing: \(error.localizedDescription)")
                    speed = 0.0
               }

                do {
                    log.debug("WindGust")
                    gust = try extractFloatValue(.windGust)
                } catch {
                    log.debug("Wind gust missing: \(error.localizedDescription)")
                    gust = nil
                }

                return Wind(direction: direction,
                            speed: speed,
                            gust: gust)
            }
        }

        func extractIntValue(_ field: PropertyField) throws -> Int {
            return try propertyNode.extractValue(field.rawValue)
        }

        func extractFloatValue(_ field: PropertyField) throws -> Float {
            return try propertyNode.extractValue(field.rawValue)
        }

        func extractString(_ propertyField: PropertyField) throws -> String {
            try propertyNode.string(propertyField.rawValue)
        }

        func extractTemperature(_ propertyField: PropertyField.Temperature) throws -> TemperatureDegrees? {

            if let value = try propertyNode.extractTemperatureNamed(propertyField) {
                return value
            }

            if propertyField.required {
                throw ExtractError.nilFound(fieldName: propertyField.rawValue)
            }

            return nil
        }

        return Observation(timestamp: try timeStamp,
                           temperature: try extractTemperature(.temperature)!,
                           windChill: try extractTemperature(.windChill),
                           heatIndex: try extractTemperature(.heatIndex),
                           textDescription: try extractString(.textDescription),
                           dewPoint: try extractTemperature(.dewpoint)!,
                           wind: wind,
                           barometricPressure: try extractIntValue(.barometricPressure))

    }

}

private extension JSON {
    /**
     Extract a temperature from a temperature node.
     Not all temperate nodes are required such as windChill & HeatIndex
     So the return value is optional

     - parameter named: Name of the node to extract
     - returns: Temperature value or nil if the value was not provided
     - throws ExtractError.notFound: If the node was not found
     */
    func extractTemperatureNamed(_ field: PropertyField.Temperature) throws -> TemperatureDegrees? {
        let temperatureNode = try json(field.rawValue)
        do {
            return try TemperatureDegrees(temperatureNode.float("value"))
        } catch {
            return nil
        }
    }

    func extractValue<Value: SignedNumeric>(_ parentNode: String,
                                            valueNodeName: String = "value") throws -> Value {
        let fieldNode = try self.json(parentNode)
        return try fieldNode.extract(valueNodeName)
    }
}
