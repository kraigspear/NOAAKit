//
//  CloudLayers.swift
//  
//
//  Created by Kraig Spear on 5/13/22.
//

import Foundation

// https://www7.ncdc.noaa.gov/climvis/help_skycon.html

/// The amount of Clouds at a given layer
public enum CloudAmount: String {
    /// Clear (0 eighths of sky covered by clouds)
    case clear = "CLR"
    /// Few (1-2 eighths of sky covered by clouds)
    case few = "FEW"
    /// Scattered (3-4 eighths of sky covered by clouds)
    case scattered = "SCT"
    ///  Broken (5-7 eighths of sky covered by clouds)
    case broken = "BKN"
    /// Overcast (Sky is completely covered by clouds)
    case overcast = "OVC"
    /// Total Obscuration (Sky is not visible due to obscuring phenomena such as fog, smoke, etc.)
    case totalObscuration = "W0X"
    /// Partial Obscuration (Sky is partially not visible due to obscuring phenomena such as fog, smoke, etc.)
    case partialObscuration = "-X"
}

/// A layer of cloud cover
public struct CloudLayer {
    /// The amount of cloud cover at this given layer
    public let cloudAmount: CloudAmount
}


