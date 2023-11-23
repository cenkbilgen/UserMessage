//
//  Notification.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import Foundation


public extension Notification.Name {
    static let userMessage = Notification.Name("package.UserMessage")
    // NOTE: userInfo should be ["message": UserMessage]
}

let userInfoKey = "UserMessage.message"

public extension Error {
    func showUser(message: LocalizedStringResource? = nil) {
        let text: UserMessage.TextType = if let message {
            .localized(message)
        } else {
            .verbatim(localizedDescription)
        }
        NotificationCenter.default
            .post(name: .userMessage, object: nil, userInfo: [userInfoKey: UserMessage(text: text, level: .error)])
    }
}

public extension String {
    func showUser() {
        NotificationCenter.default
            .post(name: .userMessage, object: nil, userInfo: [userInfoKey: UserMessage(text: .verbatim(self), level: .info)])
    }
}

public extension LocalizedStringResource {
    func showUser() {
        NotificationCenter.default
            .post(name: .userMessage, object: nil, userInfo: [userInfoKey: UserMessage(text: .localized(self), level: .info)])
    }
}
