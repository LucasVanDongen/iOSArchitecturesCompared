//
//  MessageViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct MessageViewModel {
    enum Sender {
        case user
        case other
    }

    enum Status: String {
        case unread = ""
        case read = "✓"
    }

    let sentBy: Sender
    let message: String
    let sendStatus: String
    let readStatus: Status
}
