
import CoreLocation
import Foundation
import os

@available(macOS 12, *)
@available(iOS 15, *)

/// Fetch weather at a given location
public protocol NOAAFetching {
    /**
     Fetch weather for a given coordinate
     - parameter atCoordinate: The coordinate to get weather for
     - returns: Weather for the given location
     - throws `FetchError`: Thrown weather could not be fetched
     */
    func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Weather
}

/**
 Provides weather data from the National Weather Service
 */
public final class NOAA: NOAAFetching {
    private let log = LogContext.noaaKit.logger

    private lazy var noaaAPI: NOAAAPIType = {
        NOAAAPI()
    }()

    //MARK: - Public Interface

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
        let pointsJSON = try await noaaAPI.json(from: .points(coordinate: coordinate))
        log.debug("Points fetched")
        let noaaURLS = try Extract.noaaURLS(from: pointsJSON)

        guard let observationURL = URL(string: noaaURLS.observationStations) else {
            log.error("parseFailed: observationStations")
            throw FetchError.parseFailed(field: "observationStations")
        }

        log.debug("observationURL: \(observationURL.absoluteString)")
        let observationJSON = try await noaaAPI.json(from: .observations(url: observationURL))
        log.debug("Extracting observations")
        let observations = try await Extract.observation(from: observationJSON)

        log.debug("observations extracted")

        return Weather(observations: observations)
    }
}

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
    /// The response from a call was not a HTTP response.
    /// This is highly unexpected
    case responseIsNotHTTP
}
