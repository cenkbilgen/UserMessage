//
//  UserMessage.swift
//
//
//  Created by Cenk Bilgen on 2023-11-23.
//

import Foundation

public struct UserMessage: Identifiable {
    public let id = UUID()
    
    public enum TextType: Equatable {
        case verbatim(String)
        case localized(LocalizedStringResource)

        static public func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                case (.verbatim(let lv), .verbatim(let rv)):
                    return lv == rv
                case (.localized(let lv), .localized(let rv)):
                    return lv == rv
                default:
                    return false
            }
        }
    }
    public let text: TextType

    public enum Level {
        case info
        case error
    }
    public let level: Level

    // public var duration: Duration? // Custom duration per message
}

extension UserMessage {
    // checks contents, not same as Equatable
    func matches(_ other: UserMessage) -> Bool {
        text == other.text && level == other.level
    }
}
