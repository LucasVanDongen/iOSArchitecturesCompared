//
//  DateRenderer.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 16/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

class DateRenderer {
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }

    class func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
