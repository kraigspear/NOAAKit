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
    /// The latitude in degrees.
    public let latitude: CLLocationDegrees
    /// The longitude in degrees.
    public let longitude: CLLocationDegrees

    /**
     Create a Coordinate object with the specified latitude and longitude values
     - parameter latitude: The latitude in degrees.
     - parameter longitude: The longitude in degrees.
     */
    public init(latitude: CLLocationDegrees,
                longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /**
     Create a Coordinate object with the specified coordinate
     - parameter coordinate: The coordinate that defines this `Coordinate`
     */
    public init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude,
                  longitude: coordinate.longitude)
    }

    /// Convert this `Coordinate` to a `CLLocationCoordinate2D`
    public func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - CustomStringConvertible
    public var description: String {
        "Lat: \(latitude) Lng: \(longitude)"
    }
}
