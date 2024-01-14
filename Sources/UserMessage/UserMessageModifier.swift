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
    public let colors: [UserMessage.Level: Color]
    public var allowDuplicateMessages = false
    public var multipleMessageAlignment: HorizontalAlignment = .center
    @ViewBuilder public var messageView: (UserMessage) -> V

    @State private var messages: [UserMessage] = []

    public init(notificationName: Notification.Name = .userMessage,
                duration: Duration = .seconds(6),
                location: VerticalAlignment = .top,
                colors: [UserMessage.Level: Color] = [.info: .gray, .error: .red],
                allowDuplicateMessages: Bool = true,
                multipleMessageAlignment: HorizontalAlignment = .center,
                messageView: @escaping (UserMessage) -> V) {
        self.notificationName = notificationName
        self.duration = duration
        self.location = location
        self.colors = colors
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
                        // messageView(message)
                        UserMessageView(text: message.text, color: colors[message.level, default: .gray], shape: RoundedRectangle(cornerRadius: 4))
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
                .padding(.horizontal)
                // .containerRelativeFrame(.horizontal)
            }
    }
}
