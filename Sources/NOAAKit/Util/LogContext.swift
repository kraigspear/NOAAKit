//
//  LogContext.swift
//
//
//  Created by Kraig Spear on 1/7/22.
//

import Foundation
import os

enum LogContext: String {
    case noaaKit = "☁️NOAAKit"
    case observationsExtractor = "👀ObservationsExtractor"

    var logger: os.Logger {
        os.Logger(subsystem: "com.spearware.NOAAKit", category: rawValue)
    }
}
