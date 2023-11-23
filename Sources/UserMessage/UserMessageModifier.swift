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

    @State private var messages: [(LocalizedStringResource, level: UserMessageLevel)] = []

    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName)
                .filter {
                    $0.name == .userMessage
                }) { notification in
                guard let text = notification.userInfo?["UserMessage.Text"] as? LocalizedStringResource else {
                    print("Unexpected UserMessage UserInfo")
                    return
                }
                let level = notification.userInfo?["UserMessage.Level"] as? UserMessageLevel ?? .info
                if allowDuplicateMessages || messages.contains(where: {
                    $0.0 == text && $0.1 == level
                }) {
                    messages.append((text, level))
                }
                Task {
                    try await Task.sleep(for: duration, tolerance: .seconds(0.5), clock: .continuous)
                    messages.removeFirst()
                }
            }
            .overlay(alignment: Alignment(horizontal: multipleMessageAlignment, vertical: location)) {
                VStack(alignment:  multipleMessageAlignment) {
                    ForEach(messages.indices, id: \.self) { index in
                        let text = messages[0].0
                        let isError = messages[index].level == .error // just differentiating errors
                        UserMessage(text: text,
                                    color: isError ? .red : color,
                                    shape: Rectangle())
                        .transition(.asymmetric(insertion: .opacity
                            .animation(.easeInOut(duration: 0.1)),
                                                removal: .opacity
                            .animation(.easeOut(duration: 0.8))))
                    }
                }
            }
    }
}
