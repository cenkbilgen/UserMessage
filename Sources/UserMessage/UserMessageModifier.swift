//
//  UserMessageModifier.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct ShowUserMessageModifier<V: View>: ViewModifier {
    public let notificationName: Notification.Name
    public let location: VerticalAlignment
    public let duration: Duration
    public let allowDuplicateMessages: Bool
    public let maxDisplayedMessageCount: Int
    public let multipleMessageAlignment: HorizontalAlignment
    @ViewBuilder public var messageView: (UserMessage) -> V

    public init(notificationName: Notification.Name, location: VerticalAlignment, duration: Duration, allowDuplicateMessages: Bool, maxDisplayedMessageCount: Int, multipleMessageAlignment: HorizontalAlignment, messageView: @escaping (UserMessage) -> V) {
        self.notificationName = notificationName
        self.location = location
        self.duration = duration
        self.allowDuplicateMessages = allowDuplicateMessages
        self.multipleMessageAlignment = multipleMessageAlignment
        self.maxDisplayedMessageCount = maxDisplayedMessageCount
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
                    if messages.count > maxDisplayedMessageCount {
                        messages = Array(messages.dropFirst(messages.count-maxDisplayedMessageCount))
                    }
                }
            }
            .overlay(alignment: Alignment(horizontal: multipleMessageAlignment, vertical: location)) {
                VStack {
                    ForEach(messages) { message in
                        messageView(message)
                            .animation(.none, value: message)
                            .transition(.asymmetric(insertion: .push(from: location.edge), removal: .push(from: location.oppositeEdge)))
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
                .ignoresSafeArea(.keyboard)
                .padding([location == .bottom ? .bottom : .top], 20)
            }
            .animation(.spring, value: messages)
    }
}

fileprivate extension VerticalAlignment {
    var edge: Edge {
        return switch self {
        case .bottom:
                .bottom
        case .top:
                .top
        default:
                .leading
        }
    }
    var oppositeEdge: Edge {
        return switch self {
        case .bottom:
                .top
        case .top:
                .bottom
        default:
                .trailing
        }
    }
}

public extension View {
    func showsUserMessages<V: View>(notificationName: Notification.Name = .userMessage,
                                    location: VerticalAlignment = .top,
                                    duration: Duration = .seconds(20),
                                    allowDuplicateMessages: Bool = true,
                                    maxDisplayedMessagesCount: Int = 5,
                                    multipleMessageAlignment: HorizontalAlignment = .center,
                                    @ViewBuilder messageView: @escaping (UserMessage) -> V) -> some View {
        modifier(ShowUserMessageModifier(notificationName: notificationName,
                                         location: location,
                                         duration: duration,
                                         allowDuplicateMessages: allowDuplicateMessages,
                                         maxDisplayedMessageCount: maxDisplayedMessagesCount,
                                         multipleMessageAlignment: .center,
                                         messageView: messageView))
    }

    func showsUserMessages<BR: ShapeStyle>(notificationName: Notification.Name = .userMessage,
                                           location: VerticalAlignment = .top,
                                           duration: Duration = .seconds(6),
                                           allowDuplicateMessages: Bool = true,
                                           maxDisplayedMessagesCount: Int = 5,
                                           multipleMessageAlignment: HorizontalAlignment = .center,
                                           backgroundStyle: some ShapeStyle = Material.regular,
                                           font: Font = .caption.weight(.medium),
                                           borderStyles: ([UserMessage.Level: BR], default: BR) = ([.error: .red], default: .gray),
                                           borderWidth: CGFloat = 2,
                                           shadowRadius: CGFloat = 4) -> some View {
        self.showsUserMessages(notificationName: notificationName, location: location, duration: duration, allowDuplicateMessages: allowDuplicateMessages, maxDisplayedMessagesCount: maxDisplayedMessagesCount, multipleMessageAlignment: multipleMessageAlignment) { message in
            DefaultMessageView(message: message, backgroundStyle: backgroundStyle, font: font, borderStyles: borderStyles, borderWidth: borderWidth, shadowRadius: shadowRadius)
        }
    }
}

struct DefaultMessageView<BK: ShapeStyle, BR: ShapeStyle>: View {
    let message: UserMessage
    let backgroundStyle: BK
    let font: Font
    let borderStyles: ([UserMessage.Level: BR], default: BR)
    let borderWidth: CGFloat
    let shadowRadius: CGFloat
    var body: some View {
        Text(message.string)
            .font(font)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundStyle.shadow(.drop(radius: shadowRadius)))
            .border(borderStyles.0[message.level, default: borderStyles.default], width: borderWidth)
            .padding(.horizontal)
    }
}
