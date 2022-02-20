//
//  Request.swift
//  File
//
//  Created by Kraig Spear on 7/18/21.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    var pointsRequest: URLRequest {
        let urlStr = "https://api.weather.gov/points/\(latitude),\(longitude)"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addStandardHeaders()
        return request
    }
}
