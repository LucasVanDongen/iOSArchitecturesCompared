//
//  StubMessageSender.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 17/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

protocol StubMessageSending: class {
    static func send(stub message: Message, after timeInterval: TimeInterval)
}

protocol StubMessageReading: class {
    static func read(stub message: Message, reader: String)
}

class StubMessageSender: NSObject {

    private static var activeConversations: [SimulatedConversation] = []
    private static var usedComments: [String] = []

    private static let greetings = ["Hi!", "Hey", "Long time no see", "Hello", "So you're here too? 😎"]
    private static let questions = ["What have you been up to lately?",
                                    "I haven't seen you in a while, are you still working for TopTal?",
                                    "So how's that colleague of you? 🙃",
                                    "Still going out like last year?"]
    private static var comments = ["I'm working on my thesis now",
                                   "I was hoping all is fine with you",
                                   "Some day I should get into the game again as well",
                                   "I can't remember the last time we had a beer, it's about time 🍻",
                                   "Programming some stuff, fueled by 🍕"]
    private static let salutes = ["OK, bye", "Sure, see ya 👍", "ttyl 😎", "Nice talking to you again"]

    class func triggerResponses(in simulatedConversation: SimulatedConversation, by message: Message) {
        guard !activeConversations.contains(where: { (conversation) -> Bool in
            conversation.contact == simulatedConversation.contact
        }) else {
            print("🤖: received a new message, starting automated responses again from \(simulatedConversation.contact)")
            read(message: message, of: simulatedConversation)
            return
        }

        activeConversations.append(simulatedConversation)
        print("🤖: starting a new session of automated responses with \(simulatedConversation.contact)")
        read(message: message, of: simulatedConversation) {
            print("🤖: \(simulatedConversation.contact) read your message")
            planResponse(by: simulatedConversation)
        }
    }

    class func sendGoodbyes() {
        activeConversations.forEach(planGoodbye)
        activeConversations = []
    }

    private class func read(message: Message, of simulatedConversation: SimulatedConversation,
                            whenDone finished: (() -> Void)? = nil) {
        let readDelay = Double(arc4random_uniform(4)) + 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + readDelay) {
            switch simulatedConversation.state {
            case .webSocket:
                ChatWebSocket.read(stub: message, reader: simulatedConversation.contact)
            case .inApp, .appClosed:
                break
            }

            finished?()
        }
    }

    private class func planResponse(by simulatedConversation: SimulatedConversation, responsesGiven: UInt = 0) {
        guard simulatedConversation.lastReceivedMessage.addingTimeInterval(30) > Date(),
            responsesGiven < 5 else {
                activeConversations = activeConversations.filter { $0.contact != simulatedConversation.contact }
                print("🤖: stopped automated conversation with \(simulatedConversation.contact)")
                return
        }

        let responseDelay = Double(arc4random_uniform(10)) + 5.0
        let again = responsesGiven == 0 ? "" : "again "
        print("🤖: \(simulatedConversation.contact) will send an automated response \(again)in \(responseDelay)")
        DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
            let message = Message(with: .other(name: simulatedConversation.contact),
                                  message: response(for: responsesGiven), state: .sent, sendDate: Date())

            let baseLog = "🤖: sending automated response from \(simulatedConversation.contact) through"
            switch simulatedConversation.state {
            case .webSocket:
                print("\(baseLog) web socket: \(message.message)!")
                ChatWebSocket.send(stub: message)
            case .inApp, .appClosed:
                print("\(baseLog) push: \(message.message)!")
                PushNotificationController.send(stub: message)
            }

            if case simulatedConversation.state = SimulatedConversation.State.appClosed {
                return
            }

            planResponse(by: simulatedConversation, responsesGiven: responsesGiven + 1)
        }
    }

    private class func planGoodbye(for conversation: SimulatedConversation) {
        guard conversation.lastReceivedMessage.addingTimeInterval(30) > Date() else {
            return
        }

        let goodbyeTimeInterval = Double(arc4random_uniform(10)) + 3.0
        let message = Message(with: Message.Sender.other(name: conversation.contact),
                              message: salutes.random ?? "See you!", state: .sent,
                              sendDate: Date().addingTimeInterval(goodbyeTimeInterval))

        print("🤖: sending goodbye from \(conversation.contact)")
        PushNotificationController.send(stub: message, after: goodbyeTimeInterval)
    }

    private class func response(for responseCount: UInt) -> String {
        let response: String
        switch responseCount {
        case 0: response = greetings.random ?? "Hi"
        case 1: response = questions.random ?? "How are you?"
        default:
            if comments.count == 0 {
                comments = usedComments
            }

            guard let poppedResponse = comments.popRandom() else {
                return "It's great to see you here"
            }

            response = poppedResponse
            usedComments.append(response)
        }

        return response
    }
}

fileprivate extension Array {
    private var randomIndex: Int {
        return Int(arc4random_uniform(UInt32(count)))
    }

    var random: Array.Element? {
        guard self.count > 0 else {
            return nil
        }

        return self[randomIndex]
    }

    mutating func popRandom() -> Array.Element? {
        guard self.count > 0 else {
            return nil
        }

        let randomIndex = self.randomIndex
        let element = self[randomIndex]
        self.remove(at: randomIndex)
        return element
    }
}
