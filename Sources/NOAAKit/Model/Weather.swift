//
//  Weather.swift
//
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

public struct Weather {
    public let observations: Observation

    public init(observations: Observation) {
        self.observations = observations
    }
}
