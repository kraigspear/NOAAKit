//
//  Weather.swift
//  
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

public struct Weather: Codable {
    public let currentConditions: CurrentConditions

    public init(currentConditions: CurrentConditions) {
        self.currentConditions = currentConditions
    }
}
