//
//  UserMessageView.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct UserMessageView<S: Shape, T: ShapeStyle>: View {
    let text: UserMessage.TextType
    let style: T
    var shape: S

    public init(text: UserMessage.TextType, backgroundStyle: T, shape: S) {
        self.text = text
        self.style = backgroundStyle
        self.shape = shape
    }

    public var body: some View {
        TextView(text: text)
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(style.opacity(0.9))
//            .opacity(0.9)
//            .overlay(shape
//                .stroke(style, lineWidth: 2))
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
        }
    }
}

#Preview {
    UserMessageView(text: .verbatim(CocoaError(.fileReadNoSuchFile).localizedDescription),
                    backgroundStyle: .red,
                    shape: RoundedRectangle(cornerRadius: 4))
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
