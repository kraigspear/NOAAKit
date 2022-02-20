// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stationsObservationsStations = try? newJSONDecoder().decode(StationsObservationsStations.self, from: jsonData)

import Foundation

// MARK: - StationsObservationsStations

struct StationsObservationsStations {
    let context: [StationsContextElement]
    let type: String
    let features: [StationsFeature]
    let observationStations: [String]
}

enum StationsContextElement {
    case stationsContextClass(StationsContextClass)
    case string(String)
}

// MARK: - StationsContextClass

struct StationsContextClass {
    let version: String
    let wx, s: String
    let geo, unit: String
    let vocab: String
    let geometry: StationsDistance
    let city, state: String
    let distance: StationsDistance
    let bearing: StationsBearing
    let value: StationsValue
    let unitCode: StationsDistance
    let forecastOffice, forecastGridData, publicZone, county: StationsBearing
    let observationStations: StationsObservationStations
}

// MARK: - StationsBearing

struct StationsBearing {
    let type: String
}

// MARK: - StationsDistance

struct StationsDistance {
    let id, type: String
}

// MARK: - StationsObservationStations

struct StationsObservationStations {
    let container, type: String
}

// MARK: - StationsValue

struct StationsValue {
    let id: String
}

// MARK: - StationsFeature

struct StationsFeature {
    let id: String
    let type: StationsFeatureType
    let geometry: StationsGeometry
    let properties: StationsProperties
}

// MARK: - StationsGeometry

struct StationsGeometry {
    let type: StationsGeometryType
    let coordinates: [Double]
}

enum StationsGeometryType {
    case point
}

// MARK: - StationsProperties

struct StationsProperties {
    let id: String
    let type: StationsType
    let elevation: StationsElevation
    let stationIdentifier, name: String
    let timeZone: StationsTimeZone
    let forecast, county, fireWeatherZone: String
}

// MARK: - StationsElevation

struct StationsElevation {
    let value: Double
    let unitCode: StationsUnitCode
}

enum StationsUnitCode {
    case unitM
}

enum StationsTimeZone {
    case americaDetroit
}

enum StationsType {
    case wxObservationStation
}

enum StationsFeatureType {
    case feature
}
