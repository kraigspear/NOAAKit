//
//  JSON.swift
//  File
//
//  Created by Kraig Spear on 7/25/21.
//

import Foundation

private enum DateFormatters {
    static let iso8601 = ISO8601DateFormatter()
}

typealias JSON = [String: Any]

extension JSON {
    func extractJSON(name: String) throws -> JSON {
        guard let node = self[name] as? JSON else {
            throw FetchError.parseFailed(field: name)
        }
        return node
    }

    func extractDate(name: String) throws -> Date {
        guard let dateStr = self[name] as? String else {
            throw FetchError.parseFailed(field: name)
        }
        if let date = DateFormatters.iso8601.date(from: dateStr) {
            return date
        }
        throw FetchError.parseFailed(field: name)
    }
}
