//
//  CurrentConditionExtractor.swift
//  File
//
//  Created by Kraig Spear on 7/25/21.
//

import Foundation
import SpearFoundation
import SwiftUI

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

        func observationRequest() async throws -> URLRequest {
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

        let properties = try json.json("properties")

        var temperature: Double {
            get throws {
                let temperatureNode = try properties.json("temperature")
                let temperatureCelsius = try Double(temperatureNode.float("value"))
                return Measurement(value: temperatureCelsius,
                                                        unit: UnitTemperature.celsius)
                    .converted(to: UnitTemperature.fahrenheit)
                    .value
            }
        }

        var timeStamp: Date {
            get throws {
                let fieldName = "timestamp"
                let timeStampStr = try properties.string(fieldName)
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                if let date = dateformatter.date(from: timeStampStr) {
                    return date
                }
                throw ExtractError.convertType(fieldName: fieldName)
            }
        }

        return Observation(temperature: try temperature,
                           timestamp: try timeStamp)
    }

    private func fetchStationIdentifier() async throws -> String {

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
}
