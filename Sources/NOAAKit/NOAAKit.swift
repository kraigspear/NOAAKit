
import Foundation
import CoreLocation

public enum FetchError: Error {
    case badID
    case parseFailed
    case conversion
}

@available(macOS 12, *)
@available(iOS 15, *)
public class NOAA {

    public init() {}

    public func fetchWeather(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Location {

        let request = coordinate.currentObservationRequest
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badID }

        guard let noaaForecast = try? JSONDecoder().decode(NOAAForecast.self, from: data) else {
            throw FetchError.parseFailed
        }

        let weather = Weather(current: try noaaForecast.currentObservation.toCurrent())

        return Location(
            coordinate: Coordinate(coordinate),
            weather: weather)

    }

    public func fetchTemperature(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Float {

        let request = coordinate.currentObservationRequest

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badID }

        guard let noaaForecast = try? JSONDecoder().decode(NOAAForecast.self, from: data) else {
            throw FetchError.parseFailed
        }

        if let temperature = Float(noaaForecast.currentObservation.temp) {
            return temperature
        }

        throw FetchError.conversion
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
