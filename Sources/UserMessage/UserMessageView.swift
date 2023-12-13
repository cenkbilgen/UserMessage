//
//  UserMessageView.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct UserMessageView<S: Shape>: View {
    let message: UserMessage
    let color: Color
    var shape: S

    public init(message: UserMessage, color: Color = .green, shape: S) {
        self.message = message
        self.color = color
        self.shape = shape
    }

    public var body: some View {
        TextView(text: message.text)
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(color.shadow(.drop(radius: 2)), in: shape)
            .overlay(shape
                .stroke(.primary, lineWidth: 1))
    }

    struct TextView: View {
        @Environment(\.userMessageFont) var font
        let text: UserMessage.TextType
        var body: some View {
            Group {
                switch text {
                    case .verbatim(let text):
                        Text(verbatim: text)
                    case .localized(let text):
                        Text(text)
                }
            }
                .font(font)
                .foregroundStyle(.shadow(.drop(color: .secondary, radius: 6)))
        }
    }
}

#Preview {
    UserMessageView(message: UserMessage(text: .verbatim("Hello"), level: .info), color: .gray, shape: Rectangle())
}


struct UserMessageFont: EnvironmentKey {
    static let defaultValue = Font.body
}

extension EnvironmentValues {
    var userMessageFont: Font {
        get {
            self[UserMessageFont.self]
        }
        set {
            self[UserMessageFont.self] = newValue
        }
    }
}
