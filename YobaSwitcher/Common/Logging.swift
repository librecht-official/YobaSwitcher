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
        var fileWhitelist: [String] = []
        var hashtagsWhitelist: Set<Log.Hashtag> = []
        var hashtagsBlacklist: Set<Log.Hashtag> = [.recording]
    }
    
    static var config = Config()
    
    struct Hashtag: Hashable, RawRepresentable {
        let rawValue: Int
    }
    
    static func info(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(hashtags: hashtags, sourceFile: file) {
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    static func debug(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(hashtags: hashtags, sourceFile: file) {
            debugPrint(items, separator: separator, terminator: terminator)
        }
    }
    
    static func error(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(hashtags: hashtags, sourceFile: file) {
            print("error:", terminator: "")
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    static func critical(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        hashtags: Set<Hashtag> = [],
        file: String = #file
    ) {
        filterLog(hashtags: hashtags, sourceFile: file) {
            print("critical:", terminator: "")
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    private static func filterLog(
        hashtags: Set<Hashtag>,
        sourceFile: String,
        log: () -> ()
    ) {
        let fileName = URL(fileURLWithPath: sourceFile).deletingPathExtension().lastPathComponent
        guard config.fileWhitelist.isEmpty || config.fileWhitelist.contains(fileName) else { return }
        
        guard !config.hashtagsBlacklist.contains(anyOf: hashtags) else { return }
        
        guard config.hashtagsWhitelist.isEmpty || config.hashtagsWhitelist.contains(anyOf: hashtags) else { return }
        
        log()
    }
}

extension Set {
    func contains(anyOf other: Set<Element>) -> Bool {
        !intersection(other).isEmpty
    }
}
