//
//  UserMessageModifier.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct ShowUserMessageModifier: ViewModifier {
    public var notificationName: Notification.Name = .userMessage
    public var duration: Duration = .seconds(6)
    public var location: VerticalAlignment = .top
    public var color: Color = .green
    public var allowDuplicateMessages = false
    public var multipleMessageAlignment: HorizontalAlignment = .center

    @State private var messages: [UserMessage] = []

    public init(notificationName: Notification.Name = .userMessage,
                duration: Duration = .seconds(6),
                location: VerticalAlignment = .top,
                color: Color = .blue,
                allowDuplicateMessages: Bool = true,
                multipleMessageAlignment: HorizontalAlignment = .center) {
        self.notificationName = notificationName
        self.duration = duration
        self.location = location
        self.color = color
        self.allowDuplicateMessages = allowDuplicateMessages
        self.multipleMessageAlignment = multipleMessageAlignment
    }

    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName)) { notification in
                print("Got Notification")
                guard let message = notification.userInfo?[userInfoKey] as? UserMessage else {
                    print("Unexpected UserMessage UserInfo")
                    return
                }
                if allowDuplicateMessages || !messages.contains(where: {
                    message.matches($0)
                }) {
                    print("Adding to messages")
                    messages.append(message)
                }
            }
            .overlay(alignment: Alignment(horizontal: multipleMessageAlignment, vertical: location)) {
                VStack {
                    ForEach(messages) { message in
                        let isError = message.level == .error // just differentiating errors
                        UserMessageView(message: message,
                                        color: isError ? .red : color,
                                        shape: Rectangle())
                        .task {
                            try? await Task.sleep(for: duration)
                            withAnimation(.spring()) {
                                messages.removeAll {
                                    $0.id == message.id
                                }
                            }
                        }
                    }
                }
            }
    }
}
