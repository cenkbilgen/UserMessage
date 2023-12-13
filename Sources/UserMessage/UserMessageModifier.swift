//
//  UserMessageModifier.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct ShowUserMessageModifier<V: View>: ViewModifier {
    public var notificationName: Notification.Name = .userMessage
    public var duration: Duration = .seconds(6)
    public var location: VerticalAlignment = .top
    public var color: Color = .green
    public var allowDuplicateMessages = false
    public var multipleMessageAlignment: HorizontalAlignment = .center
    @ViewBuilder public var messageView: (UserMessage) -> V

    @State private var messages: [UserMessage] = []

    public init(notificationName: Notification.Name = .userMessage,
                duration: Duration = .seconds(6),
                location: VerticalAlignment = .top,
                color: Color = .blue,
                allowDuplicateMessages: Bool = true,
                multipleMessageAlignment: HorizontalAlignment = .center,
                messageView: @escaping (UserMessage) -> V =  { m in
        UserMessageView(message: m, color: .green, shape: Rectangle())
    }) {
        self.notificationName = notificationName
        self.duration = duration
        self.location = location
        self.color = color
        self.allowDuplicateMessages = allowDuplicateMessages
        self.multipleMessageAlignment = multipleMessageAlignment
        self.messageView = messageView
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
                        // TODO: Let generic view handle it
                        messageView(message)
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
