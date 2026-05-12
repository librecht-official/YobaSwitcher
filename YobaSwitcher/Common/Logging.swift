//
//  Logging.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Foundation

extension Log.Hashtag {
    static let recording = Log.Hashtag(rawValue: 1)
}

enum Log {
    struct Config {
        var logLevel: Level = .debug
        var fileWhitelist: [String] = []
        var hashtagsWhitelist: Set<Log.Hashtag> = []
        var hashtagsBlacklist: Set<Log.Hashtag> = [.recording]
    }
    
    static var config = Config()
    
    enum Level: Int {
        case debug = 0
        case info
        case error
        case critical
    }
    
    struct Hashtag: Hashable, RawRepresentable {
        let rawValue: Int
    }
    
    private static func printDateTime() {
        print(Date().ISO8601Format(.iso8601.time(includingFractionalSeconds: true)), terminator: " ")
    }
    
    static func debug(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file,
        function: StaticString = #function
    ) {
#if DEBUG
        filterLog(level: .debug, hashtags: hashtags, sourceFile: file) {
            printDateTime()
            print("🐞 [\(function)]", terminator: ": ")
            debugPrint(item(), separator: separator, terminator: terminator)
        }
#endif
    }
    
    static func info(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(level: .info, hashtags: hashtags, sourceFile: file) {
            printDateTime()
            print("ℹ️", terminator: " ")
            print(item(), separator: separator, terminator: terminator)
        }
    }
    
    static func error(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(level: .error, hashtags: hashtags, sourceFile: file) {
            printDateTime()
            print("⚠️", terminator: " ")
            print(item(), separator: separator, terminator: terminator)
        }
    }
    
    static func critical(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(level: .critical, hashtags: hashtags, sourceFile: file) {
            printDateTime()
            print("☠️", terminator: " ")
            print(item(), separator: separator, terminator: terminator)
        }
    }
    
    private static func filterLog(
        level: Level,
        hashtags: Set<Hashtag>,
        sourceFile: String,
        log: () -> ()
    ) {
        let fileName = URL(fileURLWithPath: sourceFile).deletingPathExtension().lastPathComponent
        
        guard level >= config.logLevel,
              !config.hashtagsBlacklist.contains(anyOf: hashtags),
              config.hashtagsWhitelist.isEmpty || config.hashtagsWhitelist.contains(anyOf: hashtags),
              config.fileWhitelist.isEmpty || config.fileWhitelist.contains(fileName)
        else { return }
        
        log()
    }
}

extension Set {
    func contains(anyOf other: Set<Element>) -> Bool {
        !intersection(other).isEmpty
    }
}

extension Log.Level: Comparable {
    static func < (lhs: Log.Level, rhs: Log.Level) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<T>(_ optional: T?) {
        if let value = optional {
            appendInterpolation("\(value)")
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
