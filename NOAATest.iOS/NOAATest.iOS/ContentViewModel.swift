//
//  ContentViewModel.swift
//  NOAATest.iOS
//
//  Created by Kraig Spear on 6/21/21.
//

import Foundation
import Combine
import NOAAKit
import CoreLocation

final class ContentViewModel: ObservableObject {

    @Published var temperature = ""

    func reload() async {

        let coordinate = CLLocationCoordinate2D (
            latitude: 42.7892,
            longitude: -85.5167)


        let noaa = NOAA()

        do {
            if let weather = try await noaa.fetchWeather(atCoordinate: coordinate).weather {
                self.temperature = "\(weather.current.temperature.actual)"
            }
        } catch {
            print("Error: \(error)")
        }
    }

}
