
import Foundation
import CoreLocation

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

public protocol NOAAFetching {
    func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> WeatherLocation
}

/**
 Provides weather data from the National Weather Service
 */
public class NOAA: NOAAFetching {

    private let dateFormatter = ISO8601DateFormatter()

    /// Creates a new ``NOAA``
    public init() {
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
        let noaaURLS = try await coordinate.fetchPoints()

        func fetchStationIdentifier() async throws -> String {

            let observationStationElement = "observationStations"
            let stationIdentifierElement = "stationIdentifier"
            let featuresElement = "features"
            let propertyElement = "properties"

            guard let stationsURL = URL(string: noaaURLS.observationStations) else {
                throw FetchError.parseFailed(field: observationStationElement)
            }

            var stationRequest = URLRequest(url: stationsURL)
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

        func currentConditions() async throws -> CurrentConditions {

            let stationIdentifier = try await fetchStationIdentifier()

            let observationURL = URL(string: "https://api.weather.gov/stations/\(stationIdentifier)/observations/latest")!
            var observationRequest = URLRequest(url: observationURL)
            observationRequest.addStandardHeaders()

            let json = try await observationRequest.fetchJSON()

            guard let propertyNode = json["properties"] as? JSON else {
                throw FetchError.parseFailed(field: "properties")
            }

            guard let temperatureNode = propertyNode["temperature"] as? JSON else {
                throw FetchError.parseFailed(field: "temperature")
            }

            guard let temperatureValue = temperatureNode["value"] as? Double else {
                throw FetchError.parseFailed(field: "value")
            }

            let actual = Int(Measurement(value: temperatureValue, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value)
            let temperature = Temperature(actual: actual, feelsLike: actual)

            let date = try parseDate(propertyNode, name: "timestamp")

            return CurrentConditions(date: date, temperature: temperature)
        }

        let weather = Weather(currentConditions: try await currentConditions())

        return WeatherLocation(
            coordinate: Coordinate(coordinate),
            weather: weather)
    }

    private func parseDate(_ json: JSON, name: String) throws -> Date {
        guard let dateStr = json[name] as? String else {
            throw FetchError.parseFailed(field: name)
        }
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        throw FetchError.parseFailed(field: name)
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


