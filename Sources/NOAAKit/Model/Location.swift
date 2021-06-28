//
//  Location.swift
//  
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

public struct Location: Codable {
    public let coordinate: Coordinate
    public var weather: Weather?
}
