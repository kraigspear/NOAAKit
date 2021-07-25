//
//  CurrentConditionExtractor.swift
//  File
//
//  Created by Kraig Spear on 7/25/21.
//

import Foundation
import SwiftUI

/**
 Extract out current condition from JSON
 */
struct CurrentConditionExtractor {

    private let observationStationURL: URL

    init(observationStationURL: URL) {
        self.observationStationURL = observationStationURL
    }

    func extract() async throws -> CurrentConditions {

        let request = try await observationRequest()
        let json = try await request.fetchJSON()

        let propertyNode = try json.extractJSON(name: "properties")
        let temperature = try propertyNode.extractTemperature()
        let date = try propertyNode.extractDate(name: "timestamp")

        return CurrentConditions(date: date,
                                 temperature: temperature,
                                 clouds: 0)
    }

    private func observationRequest() async throws -> URLRequest {
        let stationIdentifier = try await fetchStationIdentifier()
        let observationURL = URL(string: "https://api.weather.gov/stations/\(stationIdentifier)/observations/latest")!
        var observationRequest = URLRequest(url: observationURL)
        observationRequest.addStandardHeaders()
        return observationRequest
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

private extension JSON {
    func extractTemperature() throws -> Temperature {

        let temperatureField = "temperature"
        let windChillField = "windChill"
        let heatIndexField = "heatIndex"

        guard let temperatureValue: Double = try extractValue(name: temperatureField) else {
            throw FetchError.parseFailed(field: temperatureField)
        }

        let feelsLike: Double

        if let windChillValue: Double = try extractValue(name: windChillField) {
            feelsLike = windChillValue
        } else if let heatIndex: Double = try extractValue(name: heatIndexField) {
            feelsLike = heatIndex
        } else {
            feelsLike = temperatureValue
        }

        return Temperature(actual: Int(Measurement(value: temperatureValue, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value),
                           feelsLike: Int(Measurement(value: feelsLike, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value))
    }
}
