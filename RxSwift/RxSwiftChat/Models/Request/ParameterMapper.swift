//
//  ParameterMapper.swift
//
//  Created by Lucas van Dongen on 5/19/17.
//  Copyright © 2017 Lucas van Dongen. All rights reserved.
//

import UIKit

class ParameterMapper: NSObject {
    class func map(key: String, value: Any) -> String {
        let stringValue: String
        switch value {
        case let dict as [String: Any]:
            stringValue = dict.map({ (key: String, value: Any) -> String in
                ParameterMapper.map(key: key, value: value)
            }).joined(separator: "&")
        case let convertible as BodyParameterConvertible:
            stringValue = convertible.bodyParameter
        default:
            stringValue = "\(key)=\(value)"
        }

        return stringValue
    }
}
