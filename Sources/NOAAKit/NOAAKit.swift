
import Foundation
import CoreLocation

/// Error that can happen when fetching weather
public enum FetchError: Error {
    /// The status code indicated that the call was unsuccessful
    /// - parameter code: The code other than 200 that was returned
    case statusCode(code: Int)
    /// Unable to parse the response. The code possibly makes incorrect assumptions about the data model
    case parseFailed
    ///
    case conversion
}

@available(macOS 12, *)
@available(iOS 15, *)
/**
 Provides weather data from the National Weather Service
 */
public class NOAA {

    /// Handles converting the NOAA data model ``NOAAModel.CurrentObservation`` to a ``CurrentConditions``
    private let currentConditionsExtractor: CurrentConditionsExtractable
    /// Fetches data from the NOAA MapClick API / Service
    private let mapClickService: MapClickServiceFetching

    /// Creates a new ``NOAA``
    public init() {
        self.currentConditionsExtractor = CurrentConditionExtractor()
        self.mapClickService = MapClickService()
    }

    /**
     Creates a new ``NOAA`` with the extractors used to convert models
     - parameters:
       - currentConditionsExtractor: Handles converting the NOAA data model ``NOAAModel.CurrentObservation`` to a ``CurrentConditions``
       - mapClickService: Fetches the response from the MapClick service
     */
    init(currentConditionsExtractor: CurrentConditionsExtractable,
         mapClickService: MapClickServiceFetching) {
        self.currentConditionsExtractor = currentConditionsExtractor
        self.mapClickService = mapClickService
    }

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
    public func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> WeatherLocation {

        func currentConditions() async throws -> CurrentConditions {
            let mapClickResponse = try await mapClickService.fetch(atCoordinate: coordinate)
            return try currentConditionsExtractor.extract(mapClickResponse.currentObservation)
        }

        let weather = Weather(currentConditions: try await currentConditions())

        return WeatherLocation(
            coordinate: Coordinate(coordinate),
            weather: weather)

    }
}


