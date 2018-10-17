//
//  CreateChatViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 21/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct CreateChatViewModel {
    let hideError: Bool
    let enableCreate: Bool
    let showSpinner: Bool
    let error: String
    let create: (String) -> Void
}
