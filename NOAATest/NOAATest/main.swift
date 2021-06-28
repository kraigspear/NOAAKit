//
//  main.swift
//  NOAATest
//
//  Created by Kraig Spear on 6/20/21.
//

import Foundation
import CoreLocation
import NOAAKit

@main
struct Main {

    static func main() async throws {
        let api = NOAA()

        let caledoniaCoordinate = CLLocationCoordinate2D(latitude: 42.7892, longitude: -85.5167)

        do {
            let temperature = try await api.fetchTemperature(atCoordinate: caledoniaCoordinate)
            print("\(temperature)")
        } catch {
            print("Error \(error)")
        }
    }
}

