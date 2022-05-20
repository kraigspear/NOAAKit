//
//  ContentViewModel.swift
//  NoaaTest
//
//  Created by Kraig Spear on 7/14/21.
//

import Combine
import CoreLocation
import Foundation
import NOAAKit
import SpearFoundation

final class ContentViewModel: ObservableObject {
    // MARK: - Published

    @Published var updatedOn = ""
    @Published var temperature = ""
    @Published var dewPoint = ""
    @Published var feelsLike: String?
    @Published var textDescription = ""

    @Published var wind = ""
    @Published var visibility = ""
    @Published var relativeHumidity = ""

    @Published var cloudLayers: [CloudLayer] = []

    @Published var errorMessage: String?

    // MARK: - Init

    init(noaaFetching: NOAAFetching = NOAA(),
         measurementConvert: MeasurementConvertable = MeasurementConverter(),
         local: LocaleType = Locale.current) {
        noaa = noaaFetching
        self.measurementConvert = measurementConvert
        self.local = local
        dateFormatter.timeStyle = .short
    }

    // MARK: - Members

    /// Fetch weather from NOAA
    private let noaa: NOAAFetching
    private let dateFormatter = DateFormatter()
    private let local: LocaleType

    /// Converts from one unit to another
    private let measurementConvert: MeasurementConvertable

    private var weatherLocation: Weather? {
        didSet {
            Task {
                await updateWeatherInfo(weather: weatherLocation)
            }
        }
    }

    @MainActor
    private func updateWeatherInfo(weather: Weather?) {
        guard let observation = weatherLocation?.observations else {
            temperature = ""
            updatedOn = ""
            return
        }

        temperature = observation.temperature.formatAsTemperature()
        dewPoint = observation.dewPoint.formatAsTemperature()

        func updateWindChill() {
            if let windChill = observation.windChill {
                feelsLike = windChill.formatAsTemperature()
            } else if let heatIndex = observation.heatIndex {
                feelsLike = heatIndex.formatAsTemperature()
            } else {
                feelsLike = nil
            }
        }

        updateWindChill()
        updatedOn = dateFormatter.string(from: observation.timestamp)
        textDescription = observation.textDescription

        var wind: String {
            let standard = observation.wind.toStandard()
            return standard.description
        }

        self.wind = wind

        func formattedDistance(_ value: Int) -> String {
            let convertedValue = measurementConvert.distanceMetersToMiles(meters: value)
            let suffix = local.usesMetricSystem ? "meter(s)" : "mile(s)"
            return "\(convertedValue)\(suffix)"
        }

        self.visibility = formattedDistance(Int(observation.visibility))

        if let relativeHumidity = observation.relativeHumidity {
            self.relativeHumidity = "\(relativeHumidity)%"
        } else {
            self.relativeHumidity = "Missing"
        }

        self.cloudLayers = observation.cloudLayers
    }

    @MainActor
    private func updateErrorMessage(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }

    // MARK: - Internal Methods

    func refresh() async {
        Task {
            let coordinate = CLLocationCoordinate2D(latitude: 42.7892, longitude: -85.5167)
            do {
                weatherLocation = try await noaa.fetchWeather(atCoordinate: coordinate)
            } catch {
                await updateErrorMessage(error.localizedDescription)
                print("error: \(error.localizedDescription)")
            }
        }
    }
}

private extension Double {
    func formatAsTemperature(local: Locale = Locale.current) -> String {

        let temperature: Int

        if local.usesMetricSystem {
            temperature = Int(self)
        } else {
            temperature = Int(Measurement(value: self, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value)
        }

        let suffix = local.usesMetricSystem ? "℃" : "℉"
        return "\(temperature)\(suffix)"
    }
}
