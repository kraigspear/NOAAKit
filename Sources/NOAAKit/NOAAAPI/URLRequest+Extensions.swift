//
//  URLRequest+Extensions.swift
//  File
//
//  Created by Kraig Spear on 7/18/21.
//

import Foundation



extension URLRequest {
    /**
     Fetch Data from web expecting a HTTPURLResponse
     returns: Data with
     */
    func fetchData() async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: self)
        guard let httpURLResponse = response as? HTTPURLResponse else {
            preconditionFailure("Expected HTTPURLResponse")
        }
        guard httpURLResponse.statusCode == 200 else { throw FetchError.statusCode(code: httpURLResponse.statusCode)}
        print("Data Fetched for \(String(describing: self.url))")
        return data
    }

    func fetchJSON() async throws -> JSON {
        let data = try await fetchData()

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
            preconditionFailure("Data is not JSON")
        }

        print("Data Fetched for url: \(String(describing: self.url)) json: \(json)")

        return json
    }

    mutating func addStandardHeaders() {
        addValue("NOAAKit", forHTTPHeaderField: "User-Agent")
        addValue("application/json", forHTTPHeaderField: "Accept")
    }
}
