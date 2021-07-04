//
//  CurrentConditionExtractor.swift
//  
//
//  Created by Kraig Spear on 7/3/21.
//

import Foundation

enum CurrentConditionExtractorError: Error {
    case dateParseError
    case temperatureParseError
}

/// A type that can transform a `CurrentObservation` and convert to a `CurrentConditions`
protocol CurrentConditionsExtractable {
    /**
     Extract `CurrentConditions` from a `CurrentObservation`
     */
    func extract(_ currentObservation: MAPClickResponse.CurrentObservation) throws -> CurrentConditions
}

final class CurrentConditionExtractor: CurrentConditionsExtractable {

    private let dateFormatter: DateFormatter

    init(dateFormatter: DateFormatter = NOAADateFormatter.noaaFromatter) {
        self.dateFormatter = dateFormatter
    }

    /**
     Extract `CurrentConditions` from a `CurrentObservation`
     */
    func extract(_ currentObservation: MAPClickResponse.CurrentObservation) throws -> CurrentConditions {
        guard let date = dateFormatter.date(from: currentObservation.date) else { throw CurrentConditionExtractorError.dateParseError }

        let temperature: Temperature

        do {
            temperature = try currentObservation.temperature
        } catch {
            throw CurrentConditionExtractorError.temperatureParseError
        }

        return CurrentConditions(date: date,
                       temperature: temperature)
    }

}

extension MAPClickResponse.CurrentObservation {
    var temperature: Temperature {
        get throws {
            try Temperature(actual: actual, feelsLike: feelsLike)
        }
    }

    private var actual: TemperatureDegrees {
        get throws {
            if let temperature = TemperatureDegrees(self.temp) {
                return temperature
            }
            throw MAPClickResponse.ParseError.parseError(field: "temp")
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
