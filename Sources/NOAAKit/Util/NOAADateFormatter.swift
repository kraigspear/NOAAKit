//
//  DateFormatter.swift
//  
//
//  Created by Kraig Spear on 7/3/21.
//

import Foundation


/// DateFormatters used with parsing
final class NOAADateFormatter {

    /// Formatter for 3 Jul 14:53 pm EDT
    static var noaaFromatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM HH:mm a zzz"
        return dateFormatter
    }()

}
