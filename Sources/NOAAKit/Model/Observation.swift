
import Foundation

// MARK: - Observations

/**
 Model for https://api.weather.gov/stations/KGRR/observations/latest
 */
public struct Observation {
    /// Date/Time when observation was observed
    public let timestamp: Date
    public let temperature: TemperatureDegrees
    /// Windchill or nil, if not relevant
    public let windChill: TemperatureDegrees?
    /// heatIndex or nil, if not relevant
    public let heatIndex: TemperatureDegrees?
}
