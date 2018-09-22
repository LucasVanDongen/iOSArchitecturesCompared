//
//  ChatViewModel.swift
//  MVVMChat
//
//  Created by Lucas van Dongen on 20/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct ChatViewModel {
    let shouldAnimateChanges: Bool
    let shouldWipeMessage: Bool
    let shouldBeBusy: Bool
    let shouldShowEmpty: Bool
    let shouldShowError: Bool
    let error: String?
    let contact: String
    let messages: [MessageViewModel]
    let tableViewDifferences: TableViewDataDifferences
    let send: (String) -> Void
    let reloaded: () -> Void
}
