//
//  CurrentConditionExtractor.swift
//
//  Created by Kraig Spear on 7/25/21.
//

import Foundation
import SpearFoundation
import SwiftUI

/**
 Extract out a DataModel from JSON
 */
struct Extract {

    //MARK: - Observation

    /**
     Extract an `Observation` from the given station URL
     - parameter from: The URL for an Observation Station
     - throws `FetchError.parseFailed`: The data could not be parsed
     */
    static func observation(from json: JSON) async throws -> Observation {

        let log = LogContext.observationsExtractor.logger
        let propertyNode = try json.json("properties")

        // Parse Fields
        var temperature: TemperatureDegrees {
            get throws {
                log.debug("Extract Temperature")
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
                log.debug("Extract timestamp")
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
                log.debug("Extract windChill")
                return try propertyNode.extractTemperatureNamed(.windChill)
            }
        }

        var heatIndex: TemperatureDegrees? {
            get throws {
                log.debug("extract heatIndex")
                return try propertyNode.extractTemperatureNamed(.heatIndex)
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
                    direction = try propertyNode.extractIntValue(.windDirection)
                } catch {
                    log.warning("Wind direction missing: \(error.localizedDescription)")
                    direction = 0
                }

                do {
                    log.debug("WindSpeed")
                    speed = try propertyNode.extractFloatValue(.windSpeed)
                } catch {
                    log.warning("Wind speed missing: \(error.localizedDescription)")
                    speed = 0.0
                }

                do {
                    log.debug("WindGust")
                    gust = try propertyNode.extractFloatValue(.windGust)
                } catch {
                    log.debug("Wind gust missing: \(error.localizedDescription)")
                    gust = nil
                }

                return Wind(direction: direction,
                            speed: speed,
                            gust: gust)
            }
        }

        var cloudLayers: [CloudLayer] {
            get throws {
                let cloudNodes = try propertyNode.jsonArray(PropertyField.cloudLayers.rawValue)
                return try cloudNodes.map {
                    let stringAmount = try $0.string("amount")
                    log.debug("CloudAmount: \(stringAmount)")
                    if let cloudAmount = CloudAmount(rawValue: stringAmount) {
                        return CloudLayer(cloudAmount: cloudAmount)
                    } else {
                        log.error("Didn't find CloudAmount for value \(stringAmount)")
                        throw ExtractError.enumElementNotFound(fieldName: "cloudLayers.amount", elementValue: stringAmount)
                    }
                }
            }
        }

        func extractTemperature(_ propertyField: PropertyField.Temperature) throws -> TemperatureDegrees? {

            log.debug("extractTemperature field: \(propertyField.rawValue)")
            if let value = try propertyNode.extractTemperatureNamed(propertyField) {
                return value
            }

            if propertyField.required {
                throw ExtractError.nilFound(fieldName: propertyField.rawValue)
            }

            return nil
        }

        // Build Model
        return Observation(timestamp: try timeStamp,
                           temperature: try extractTemperature(.temperature)!,
                           windChill: try extractTemperature(.windChill),
                           heatIndex: try extractTemperature(.heatIndex),
                           textDescription: try propertyNode.extractString(.textDescription),
                           dewPoint: try extractTemperature(.dewpoint)!,
                           wind: wind,
                           barometricPressure: try propertyNode.extractIntValue(.barometricPressure),
                           visibility: try propertyNode.extractIntValue(.visibility),
                           relativeHumidity: try propertyNode.extractIntValue(.relativeHumidity),
                           cloudLayers: try cloudLayers)

    }

    //MARK: - noaaURLS

    /**
     Extract out `NOAAURLS` from a JSON Payload
     - parameter from: The JSON to extract out `NOAAURLS` from
     - returns: URL's for various API calls for a given location
     - throws parseFailed: If the JSON does not contain expected elements
     */
    static func noaaURLS(from json: JSON) throws -> NOAAURLS {
        let propertyField = "properties"
        let stationField = "observationStations"

        guard let properties = json[propertyField] as? JSON else {
            throw FetchError.parseFailed(field: propertyField)
        }

        if let observationStations = properties[stationField] as? String {
            return NOAAURLS(observationStations: observationStations)
        }

        throw FetchError.parseFailed(field: stationField)
    }

}

// MARK: - JSON
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

    func extractIntValue(_ field: PropertyField) throws -> Int {
        return try extractValue(field.rawValue)
    }

    func extractFloatValue(_ field: PropertyField) throws -> Float {
        return try extractValue(field.rawValue)
    }

    func extractString(_ propertyField: PropertyField) throws -> String {
        try string(propertyField.rawValue)
    }

    func extractValue<Value: SignedNumeric>(_ parentNode: String,
                                            valueNodeName: String = "value") throws -> Value {
        let fieldNode = try self.json(parentNode)
        return try fieldNode.extract(valueNodeName)
    }
}

// MARK: - Payload Properties

/**
 Properties from the Observation Payload
 */
private enum PropertyField: String {
    case timestamp
    case textDescription
    case windDirection
    case windSpeed
    case windGust
    case barometricPressure
    case visibility
    case relativeHumidity
    case cloudLayers
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
