//
//  Weather.swift
//
//
//  Created by Kraig Spear on 6/28/21.
//

import Foundation

/**
 Weather information
 */
public struct Weather {
    /// Observation
    public let observations: Observation

    /**
     Create a ``Weather`` with the given observation
     - parameters: observations
       -
     */
    public init(observations: Observation) {
        self.observations = observations
    }
}
