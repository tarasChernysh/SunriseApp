//
//  DateFormaterService.swift
//  Sunrise
//
//  Created by Taras Chernysh on 5/9/19.
//  Copyright © 2019 Ihor Chernysh. All rights reserved.
//

import Foundation


final class DateFormatterService {
    private init() {}
    static let shared = DateFormatterService()
    
    private let utcDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    private let localTimeFormat = "hh:mm:ss a"
    
    func convertToLocalDate(utcDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = utcDateFormat
        guard let utcDate = dateFormatter.date(from: utcDateString) else { return "" }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = localTimeFormat
        let localDateString = dateFormatter.string(from: utcDate)
        return localDateString
    }
}
