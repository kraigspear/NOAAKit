//
//  Wind.swift
//  
//
//  Created by Kraig Spear on 2/20/22.
//

import Foundation

public struct Wind: CustomStringConvertible {
    public let direction: Int
    public let speed: Float
    /// The gust of wind, or nil if there isn't a significant wind gust
    public let gust: Float?

    public var description: String {
        var description = "Direction: \(direction) speed: \(speed)"
        if let gust = gust {
            description += " gust: \(gust)"
        }
        return description
    }

    /**
     Convert this Wind to Standard
     */
    public func toStandard() -> Wind {
        let speedMPH = Float(Measurement(value: Double(speed),
                             unit: UnitSpeed.kilometersPerHour).converted(to: .milesPerHour).value)

        let gustMPH: Float?

        if let gust = gust {
            gustMPH = Float(Measurement(value: Double(gust),
                            unit: UnitSpeed.kilometersPerHour).converted(to: .milesPerHour).value)
        } else {
            gustMPH = nil
        }

        return Wind(direction: direction,
                    speed: speedMPH,
                    gust: gustMPH)
    }
}
