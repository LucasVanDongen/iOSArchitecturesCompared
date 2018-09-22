//
//  CreateChatViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 21/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct CreateChatViewModel {
    enum State {
        case empty
        case creating
        case failed(reason: String)
    }

    let state: State
    let create: (String) -> Void
}
