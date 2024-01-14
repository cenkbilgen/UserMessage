//
//  UserMessageView.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct UserMessageView<S: Shape>: View {
    let text: UserMessage.TextType
    let color: Color
    var shape: S

    public init(text: UserMessage.TextType, color: Color, shape: S) {
        self.text = text
        self.color = color
        self.shape = shape
    }

    public var body: some View {
        TextView(text: text)
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(color.opacity(0.9), in: shape)
            .overlay(shape
                .stroke(color, lineWidth: 2))
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
                // .foregroundStyle(.shadow(.drop(color: .secondary, radius: 6)))
        }
    }
}

#Preview {
    UserMessageView(text: .verbatim(CocoaError(.fileReadNoSuchFile).localizedDescription),
                    color: .green,
                    shape: Rectangle())
    .environment(\.userMessageFont, .body.bold())
}

// Message Color

struct UserMessageColors: EnvironmentKey {
    static let defaultValue: [UserMessage.Level: Color] = [
        .info: .accentColor,
        .error: .red
    ]
}

extension EnvironmentValues {
    var userMessageColors: [UserMessage.Level: Color] {
        get {
            self[UserMessageColors.self]
        }
        set {
            self[UserMessageColors.self] = newValue
        }
    }
}

// Message Font

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
