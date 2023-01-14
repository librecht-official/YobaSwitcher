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
        var logLevel: Level = .info
        var fileWhitelist: [String] = []
        var hashtagsWhitelist: Set<Log.Hashtag> = []
        var hashtagsBlacklist: Set<Log.Hashtag> = [.recording]
    }
    
    static var config = Config()
    
    enum Level: Int {
        case trace = 0
        case debug
        case info
        case error
        case critical
    }
    
    struct Hashtag: Hashable, RawRepresentable {
        let rawValue: Int
    }
    
    static func trace(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file,
        function: StaticString = #function
    ) {
        filterLog(level: .trace, hashtags: hashtags, sourceFile: file) {
            print(function, terminator: ": ")
            print(item(), separator: separator, terminator: terminator)
        }
    }
    
    static func debug(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file,
        function: StaticString = #function
    ) {
        filterLog(level: .debug, hashtags: hashtags, sourceFile: file) {
            print(function, terminator: ": ")
            print(item(), separator: separator, terminator: terminator)
        }
    }
    
    static func info(
        _ item: @autoclosure () -> Any,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(level: .info, hashtags: hashtags, sourceFile: file) {
            print("[info]", terminator: " ")
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
            print("[error]", terminator: " ")
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
            print("[critical]", terminator: " ")
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
