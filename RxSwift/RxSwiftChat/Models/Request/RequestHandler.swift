//
//  RequestHandler.swift
//  LiveCore
//
//  Created by Lucas van Dongen on 5/20/17.
//  Copyright © 2017 Lucas van Dongen. All rights reserved.
//

import UIKit

enum Result<T: Decodable> {
    case success(result: T)
    case failure(error: String)
}

enum SingleResult<T: Decodable> {
    case success(result: T)
    case failure(error: String)
}
