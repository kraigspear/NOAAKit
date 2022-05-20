//
//  NOAAAPI.swift
//  
//
//  Created by Kraig Spear on 5/14/22.
//

import Foundation
import CoreLocation

/// Fetch from the NOAAAPI
protocol NOAAAPIType {
    /**
     Fetch a JSON Payload from the NOAA API
     - parameter apiCall: Which API
     */
    func json(from endPoint: EndPoint) async throws -> JSON
}

final class NOAAAPI: NOAAAPIType {

    //MARK: - Members
    private let log = LogContext.noaaKit.logger

    //MARK: - Accessible Methods
    func json(from endPoint: EndPoint) async throws -> JSON {
        switch endPoint {
        case let .observations(url):
            let request = try await observationRequest(observationStationURL: url)
            log.debug("Fetching Observation JSON")
            let json = try await URLSession.shared.json(from: request)
            log.debug("Observation JSON fetched")
            return json
        case let .points(coordinate):
            let request = pointsRequest(at: Coordinate(coordinate))
            let json = try await URLSession.shared.json(from: request)
            return json
        }
    }

    //MARK: - Request
    /**
     A `URLRequest` for observation at a URL
     - parameter observationStationURL: URL that gives NOAA station identifiers
     - returns: `URLRequest`
     */
    private func observationRequest(observationStationURL: URL) async throws -> URLRequest {
        var stationIdentifier: String {
            get async throws {
                let stationIdentifierElement = "stationIdentifier"
                let featuresElement = "features"
                let propertyElement = "properties"

                let stationRequest = URLRequest.noaaRequest(url: observationStationURL)
                let stationJSON = try await URLSession.shared.json(for: stationRequest)

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

        let observationURL = URL(string: "https://api.weather.gov/stations/\(try await stationIdentifier)/observations/latest")!
        log.debug("observationURL: \(observationURL)")
        let observationRequest = URLRequest.noaaRequest(url: observationURL)
        return observationRequest
    }

    /**
     A `URLRequest` for the points call
     The points call gives URL's for a given coordinate for other NOAA Api calls
     - parameter at: The `Coordinate` to get the points for.
     - returns: A `URLRequest` to get points for a given coordinate
     */
    private func pointsRequest(at coordinate: Coordinate) -> URLRequest {
        let urlStr = "https://api.weather.gov/points/\(coordinate.latitude),\(coordinate.longitude)"
        let url = URL(string: urlStr)!
        let request = URLRequest.noaaRequest(url: url)
        return request
    }
}

/// An EndPoint for a NOAA API Call
enum EndPoint {
    /// Observations from a given Observation URL
    case observations(url: URL)
    /// Gives URL for a coordinate for various API Calls such as Observations
    case points(coordinate: CLLocationCoordinate2D)
}

