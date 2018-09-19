//
//  Message.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 15/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct Message {

    enum Sender {
        case user
        case other(name: String)
    }

    enum State {
        case sending
        case sent
        case read(readDate: Date)
    }

    let sender: Sender
    private(set) var state: State
    let message: String
    let sendDate: Date

    mutating func sent() {
        guard case .sending = state else {
            return
        }

        state = .sent
    }

    mutating func read(readDate: Date) {
        state = .read(readDate: readDate)
    }
}

extension Message: Differentiable {
    func isSame(as other: Message) -> Bool {
        guard sendDate == other.sendDate else {
            return false
        }

        return true
    }

    func hasChanged(comparedTo other: Message) -> Bool {
        switch (other.state, self.state) {
        case (.sending, .sending), (.sent, .sent), (.read, .read): return false
        case (.sending, _), (.sent, _), (.read, _): return true
        }
    }

    func isOrderedHigher(than other: Message) -> Bool {
        return other.sendDate > sendDate
    }

    func isOrderedLower(than other: Message) -> Bool {
        return other.sendDate < sendDate
    }
}
