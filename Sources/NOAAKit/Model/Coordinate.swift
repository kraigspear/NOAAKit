//
//  Coordinate.swift
//  Klimate
//
//  Created by Kraig Spear on 8/21/20.
//

import Foundation
import CoreLocation

/**
 Allows storing a coordinate outside of CoreLocation CLCoordinate2D which doesn't support
 Codable, Hashable.
 */
public struct Coordinate: Codable, Equatable, Hashable, CustomStringConvertible {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees

    public init(latitude: CLLocationDegrees,
                longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude,
                  longitude: coordinate.longitude)
    }

    public var clLocation2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var description: String {
        "Lat: \(latitude) Lng: \(longitude)"
    }
}
