//
//  URLSession+Extension.swift
//  
//
//  Created by Kraig Spear on 5/17/22.
//

import Foundation

extension URLSession {
    /**
     Execute `request` returning the JSON result
     - parameter for: The `URLRequest` to execute
     - throws FetchError.statusCode: If the status code of the response indicates failure
     - throws FetchError.dataIsNotJSON: If the response is not valid `JSON`
     */
    func json(for request: URLRequest) async throws -> JSON {
        let log = LogContext.noaaKit.logger
        log.debug("Fetching JSON for \(request)")
        let (data, response) = try await data(for: request)
        try response.isValidWebResponse()
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
            return json
        }
        throw FetchError.dataIsNotJSON
    }
}

extension URLResponse {
    /**
     Check that a URLResponse was a successful web response
     - throws FetchError.statusCode: If the response indicates failure
     */
    func isValidWebResponse() throws {
        let log = LogContext.noaaKit.logger
        guard let httpURLResponse = self as? HTTPURLResponse else {
            throw FetchError.responseIsNotHTTP
        }
        if httpURLResponse.statusCode != 200 {
            let url = self.url?.absoluteString ?? "Missing URL"
            log.error("Status code not successful for \(url)")
            throw FetchError.statusCode(code: httpURLResponse.statusCode)
        }
    }
}
