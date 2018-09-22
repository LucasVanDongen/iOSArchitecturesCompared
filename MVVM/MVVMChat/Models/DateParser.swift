//
//  DateParser.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 18/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class DateParser {
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }()

    class func date(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
