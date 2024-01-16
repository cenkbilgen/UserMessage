//
//  UserMessageModifier.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct ShowUserMessageModifier<V: View>: ViewModifier {
    public let notificationName: Notification.Name
    public let backgroundStyles: [UserMessage.Level: any ShapeStyle]
    public let location: VerticalAlignment
    public let duration: Duration
    public let allowDuplicateMessages: Bool
    public let multipleMessageAlignment: HorizontalAlignment
    @ViewBuilder public var messageView: (UserMessage) -> V

    public init(notificationName: Notification.Name, backgroundStyles: [UserMessage.Level : any ShapeStyle], location: VerticalAlignment, duration: Duration, allowDuplicateMessages: Bool, multipleMessageAlignment: HorizontalAlignment, messageView: @escaping (UserMessage) -> V) {
        self.notificationName = notificationName
        self.backgroundStyles = backgroundStyles
        self.location = location
        self.duration = duration
        self.allowDuplicateMessages = allowDuplicateMessages
        self.multipleMessageAlignment = multipleMessageAlignment
        self.messageView = messageView
    }

    @State private var messages: [UserMessage] = []

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
                        messageView(message)
                            .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                            .onTapGesture {
                                messages.removeAll {
                                    $0 == message
                                }
                            }
                            .task {
                                try? await Task.sleep(for: duration)
                                messages.removeAll {
                                    $0.id == message.id
                                }
                            }
                    }
                }
            }
            .animation(.spring, value: messages)
    }
}

public extension View {
    func showsUserMessages<V: View>(notificationName: Notification.Name = .userMessage,
                                           location: VerticalAlignment = .top,
                                           duration: Duration = .seconds(6),
                                           allowDuplicateMessages: Bool = true,
                                           multipleMessageAlignment: HorizontalAlignment = .center,
                                           @ViewBuilder messageView: @escaping (UserMessage) -> V) -> some View {
        modifier(ShowUserMessageModifier(notificationName: notificationName,
                                         backgroundStyles: [:], // let the customized messageView handle background style
                                         location: location,
                                         duration: duration,
                                         allowDuplicateMessages: allowDuplicateMessages,
                                         multipleMessageAlignment: .center,
                                         messageView: messageView))
    }

    func showsUserMessages<V: View>(notificationName: Notification.Name = .userMessage,
                                                   backgroundStyles: [UserMessage.Level: Color] = [.info: .clear, .error: .red],
                                                   location: VerticalAlignment = .top,
                                                   duration: Duration = .seconds(6),
                                                   allowDuplicateMessages: Bool = true,
                                                   multipleMessageAlignment: HorizontalAlignment = .center) -> some View {
        modifier(ShowUserMessageModifier(notificationName: notificationName,
                                         backgroundStyles: backgroundStyles,
                                         location: location,
                                         duration: duration,
                                         allowDuplicateMessages: allowDuplicateMessages,
                                         multipleMessageAlignment: .center) { message in
                UserMessageView(text: message.text,
                                backgroundStyle: backgroundStyles[message.level, default: Color.clear],
                                shape: RoundedRectangle(cornerRadius: 4))
        })
    }
}
