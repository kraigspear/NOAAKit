//
//  URLRequest+Extensions.swift
//
//  Created by Kraig Spear on 7/18/21.
//

import Foundation

extension URLRequest {
    /**
     A URLRequest for a NOAA service endpoint
     Common configuration used on all NOAA service calls

     - parameter url: The URL of the endpoint
     - returns: A URLRequest configured for a NOAA API call
     */
    static func noaaRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addStandardHeaders()
        return request
    }

    private mutating func addStandardHeaders() {
        addValue("NOAAKit", forHTTPHeaderField: "User-Agent")
        addValue("application/json", forHTTPHeaderField: "Accept")
    }
}
