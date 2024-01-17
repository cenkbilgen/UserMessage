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

    // TODO: Cleanup use gesture state with onEnded transaction for iOS17
    //@GestureState var drag: (UserMessage.ID, CGFloat)?
    @State private var draggingMessageID: UserMessage.ID?
    @State private var dragValue: CGFloat = .zero
    @State private var swipeValue: CGFloat = .zero

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
                        messageView(message)
                            .animation(.none, value: message)
                            .compositingGroup()
                            .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
                            .gesture(
                                DragGesture(coordinateSpace: .local)
                                //                                        .updating($drag, body: { value, state, transaction in
                                //                                            transaction.isContinuous = true
                                //                                            state = (message.id, value.translation.height)
                                //                                        })
                                    .onChanged { value in
                                        draggingMessageID = message.id
                                        dragValue = value.translation.height
                                        swipeValue = value.translation.width
                                    }
                                    .onEnded { _ in
                                        defer {
                                            draggingMessageID = nil
                                            dragValue = .zero
                                            swipeValue = .zero
                                        }
                                        if dragValue < -20 || abs(swipeValue) > 20 {
                                            messages.removeAll {
                                                $0 == message
                                            }
                                        }
                                    }
                                    .exclusively(before:
                                                    TapGesture()
                                        .onEnded{
                                            messages.removeAll {
                                                $0 == message
                                            }
                                        })
                            )
                        // for now disable left-right swipe dismiss
                        //                            .offset(x: draggingMessageID == message.id ? ((abs(swipeValue) > abs(dragValue)) ? swipeValue : .zero) : .zero,
                        //                                    y: draggingMessageID == message.id ? ((abs(swipeValue) < abs(dragValue)) ? dragValue : .zero) : .zero)
                            .offset(y: draggingMessageID == message.id ? dragValue : .zero)
                            .animation(.bouncy, value: dragValue)
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
                                    duration: Duration = .seconds(20),
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
