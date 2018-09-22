//
//  ApplicationBadge.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol ApplicationBadgeUpdating {
    static func update(with unreadCount: Int)
}

class ApplicationBadge: ApplicationBadgeUpdating {
    static func update(with unreadCount: Int) {
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
}
