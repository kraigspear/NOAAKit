
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

 */
public class NOAA {

    private let currentConditionsExtractor: CurrentConditionsExtractable

    public init() {
        self.currentConditionsExtractor = CurrentConditionExtractor()
    }

    init(currentConditionsExtractor: CurrentConditionsExtractable) {
        self.currentConditionsExtractor = currentConditionsExtractor
    }

    public func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> WeatherLocation {

        let request = coordinate.currentObservationRequest
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpURLResponse = response as? HTTPURLResponse else {
             preconditionFailure("Unexpected to not receive a HTTPURLResponse")
        }

        guard httpURLResponse.statusCode == 200 else { throw FetchError.statusCode(code: httpURLResponse.statusCode)}

        guard let noaaForecast = try? JSONDecoder().decode(NOAAModel.Forecast.self, from: data) else {
            throw FetchError.parseFailed
        }

        let current = try currentConditionsExtractor.extract(noaaForecast.currentObservation)

        let weather = Weather(current: current)

        return WeatherLocation(
            coordinate: Coordinate(coordinate),
            weather: weather)

    }
}

private extension CLLocationCoordinate2D {
    var currentObservationRequest: URLRequest {
        let urlStr = "https://forecast.weather.gov/MapClick.php?lat=\(latitude)&lon=\(longitude)&unit=0&lg=english&FcstType=json"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
