//
//  Notification.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import Foundation

public enum UserMessageLevel {
    case info
    case error
}

public extension Notification.Name {
    static let userMessage = Notification.Name("package.UserMessage")
    // NOTE: userInfo ["UserMessage.Text": LocalizedStringResource, "UserMessage.Level": UserMessageLevel ?? .info]
}

public extension Error {
    func showUser(message: String? = nil) {
        NotificationCenter.default
            .post(name: .userMessage, object: nil, userInfo: ["UserMessage.Text": message ?? localizedDescription,
                                                              "UserMessage.Level": UserMessageLevel.error] as? [String: Any])
    }
}

public extension String {
    func showUser() {
        NotificationCenter.default
            .post(name: .userMessage, object: nil, userInfo: ["UserMessage.Text": self,
                                                              "UserMessage.Level": UserMessageLevel.info] as? [String: Any])
    }
}

public extension LocalizedStringResource {
    func showUser() {
        self.key.showUser()
    }
}
