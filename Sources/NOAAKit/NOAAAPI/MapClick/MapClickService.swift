//
//  MapClickService.swift
//  
//
//  Created by Kraig Spear on 7/4/21.
//

import Foundation
import CoreLocation

/// Fetches the latest weather for the given coordinate using the MapClick service from NOAA
protocol MapClickServiceFetching {
    /**
     Fetch the latest ``MAPClickResponse.Root`` for a given coordinate
     - parameter atCoordinate: Coordinate to get ``MAPClickResponse.Root``
     - Returns: The ``MAPClickResponse.Root`` for the given coordinate
     - Throws FetchError.parseFailed: If the data model doesn't match the response
     */
    func fetch(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> MAPClickResponse.Root
}

@available(macOS 12, *)
@available(iOS 15, *)
/**
 Fetches the latest weather for the given coordinate using the MapClick service from NOAA

 NOAA has many weather API's that are somewhat obscure. MapClick provides current conditions for a Coordinate
 */
final class MapClickService: MapClickServiceFetching {
    /**
     Fetch the latest ``MAPClickResponse.Root`` for a given coordinate
     - parameter atCoordinate: Coordinate to get ``MAPClickResponse.Root``
     - Returns: The ``MAPClickResponse.Root`` for the given coordinate
     - Throws FetchError.parseFailed: If the data model doesn't match the response
     */
    func fetch(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> MAPClickResponse.Root {
        func fetchDataFromNOAA() async throws -> Data {
            let request = coordinate.mapClickJSONRequest
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                 preconditionFailure("Unexpected to not receive a HTTPURLResponse")
            }

            guard httpURLResponse.statusCode == 200 else { throw FetchError.statusCode(code: httpURLResponse.statusCode)}
            return data
        }

        let data = try await fetchDataFromNOAA()

        guard let root = try? JSONDecoder().decode(MAPClickResponse.Root.self, from: data) else {
            throw FetchError.parseFailed
        }

        return root
    }
}

private extension CLLocationCoordinate2D {
    /// A URLRequest for the MapClick service for this Coordinate
    var mapClickJSONRequest: URLRequest {
        let urlStr = "https://forecast.weather.gov/MapClick.php?lat=\(latitude)&lon=\(longitude)&unit=0&lg=english&FcstType=json"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
