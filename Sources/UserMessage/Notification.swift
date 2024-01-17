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
    func showUser(notificationName: Notification.Name = .userMessage, 
                  message: LocalizedStringResource? = nil) {
        let text: UserMessage.TextType = if let message {
            .localized(message)
        } else {
            .verbatim(localizedDescription)
        }
        NotificationCenter.default
            .post(name: notificationName, object: nil, userInfo: [userInfoKey: UserMessage(text: text, level: .error)])
    }
}

public extension String {
    func showUser(notificationName: Notification.Name = .userMessage, level: UserMessage.Level = .info) {
        NotificationCenter.default
            .post(name: notificationName, object: nil, userInfo: [userInfoKey: UserMessage(text: .verbatim(self), level: level)])
    }
}

public extension LocalizedStringResource {
    func showUser(notificationName: Notification.Name = .userMessage, level: UserMessage.Level = .info) {
        NotificationCenter.default
            .post(name: notificationName, object: nil, userInfo: [userInfoKey: UserMessage(text: .localized(self), level: level)])
    }
}
