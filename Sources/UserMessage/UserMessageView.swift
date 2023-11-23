//
//  UserMessageView.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import SwiftUI

public struct UserMessage<S: Shape>: View {
    @Environment(\.userMessageFont) var font
    let text: LocalizedStringResource
    let color: Color
    var shape: S

    public var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(.shadow(.drop(color: .secondary, radius: 6)))
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(color.shadow(.drop(radius: 2)), in: shape)
            .overlay(shape
                .stroke(.primary, lineWidth: 1))
    }
}

#Preview {
    UserMessage(text: "There was an error. Check Network", color: .gray, shape: Rectangle())
        .padding()
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
