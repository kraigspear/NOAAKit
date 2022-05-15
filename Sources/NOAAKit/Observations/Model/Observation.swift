
import Foundation

// MARK: - Observations

/**
 Model for https://api.weather.gov/stations/KGRR/observations/latest

 Observation of weather at a given weather station
 */
public struct Observation {
    /// Date/Time when observation was observed
    public let timestamp: Date
    /// Temperature observed
    public let temperature: TemperatureDegrees
    /// Windchill or nil, if not relevant
    public let windChill: TemperatureDegrees?
    /// heatIndex or nil, if not relevant
    public let heatIndex: TemperatureDegrees?
    /// Description of the current conditions
    public let textDescription: String
    /// DewPoint observed
    public let dewPoint: TemperatureDegrees
    /// Wind direction, speed and gust
    public let wind: Wind
    /// Barometric Pressure at the observed time
    public let barometricPressure: Int
    /// The visibility at the observed time
    public let visibility: Int
    /// Precent of relative humidity
    public let relativeHumidity: Int?
    /// Clouds at various layers being observed
    public let cloudLayers: [CloudLayer]
}
