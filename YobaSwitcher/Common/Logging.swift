//
//  Logging.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import OSLog

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
}

enum Log {
    static let app = Logger(category: "Application")
    static let recording = Logger(category: "Recording")
    static let inputProcessing = Logger(category: "GlobalInputProcessing")
    static let selectedText = Logger(category: "SelectedText")
    static let inputSource = Logger(category: "TextInputSource")
    static let events = Logger(category: "Events")
}

extension Optional: @retroactive CustomStringConvertible {
    public var description: String {
        if let value = self {
            return "\(value)"
        } else {
            return "nil"
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<T>(_ optional: T?) {
        if let value = optional {
            appendInterpolation(value)
        } else {
            appendInterpolation("nil")
        }
    }
}

struct TextError: LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? { message }
}
