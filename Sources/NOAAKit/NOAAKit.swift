
import CoreLocation
import Foundation
import os

/// Error that can happen when fetching weather
public enum FetchError: Error {
    /// The status code indicated that the call was unsuccessful
    /// - parameter code: The code other than 200 that was returned
    case statusCode(code: Int)
    /// Unable to parse the response. The code possibly makes incorrect assumptions about the data model
    case parseFailed(field: String)
    /// Failed to convert data to the expected type
    case conversion
    /// The Station ID is needed for current conditions. Possible invalid coordinates
    case stationIdentifierNotFound
    /// The data can't be converted into JSON
    case dataIsNotJSON
    case responseIsNotHTTP
}

@available(macOS 12, *)
@available(iOS 15, *)

/// Fetch weather at a given location
public protocol NOAAFetching {
    /**
     Fetch weather for a given coordinate
     - parameter atCoordinate: The coordinate to get weather for
     - returns: Weather for the given location
     */
    func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Weather
}

/**
 Provides weather data from the National Weather Service
 */
public class NOAA: NOAAFetching {
    private let dateFormatter = ISO8601DateFormatter()
    private let log = LogContext.noaaKit.logger

    /// Creates a new ``NOAA``
    public init() {}

    /**
     Fetch the location with weather for the ``Coordinate`` that was passed in.

     Calling this function will return the latest weather information for the given coordinate.
     If there is a problem either with the network or parsing a ``FetchError`` is thrown.

     - parameter atCoordinate: The coordinate of the location to get weather
     - Returns: A ``WeatherLocation`` containing the weather for this location
     - Throws: ``FetchError`` If there was a problem retrieving the latest weather information from NOAA

     ```swift
     do {
         if let weather = try await noaa.fetchWeather(atCoordinate: coordinate).weather {
             self.temperature = "\(weather.current.temperature.actual)"
         }
     } catch {
         print("Error: \(error)")
     }
     ```
     */
    public func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Weather {
        log.debug("fetchPoints")
        let noaaURLS = try await coordinate.fetchPoints()
        log.debug("Points fetched")

        guard let observationURL = URL(string: noaaURLS.observationStations) else {
            log.error("parseFailed: observationStations")
            throw FetchError.parseFailed(field: "observationStations")
        }

        log.debug("observationURL: \(observationURL.absoluteString)")
        log.debug("Extracting observations")

        let observations = try await ObservationsExtractor(observationStationURL: observationURL).extract()

        log.debug("observations extracted")

        return Weather(observations: observations)
    }
}

private extension CLLocationCoordinate2D {
    func fetchPoints() async throws -> NOAAURLS {
        let json = try await pointsRequest.fetchJSON()

        guard let properties = json["properties"] as? JSON else {
            throw FetchError.parseFailed(field: "properties")
        }

        if let observationStations = properties["observationStations"] as? String {
            return NOAAURLS(observationStations: observationStations)
        }

        throw FetchError.parseFailed(field: "observationStations")
    }
}
