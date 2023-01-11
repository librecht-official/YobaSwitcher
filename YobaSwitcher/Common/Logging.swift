//
//  Logging.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Foundation

let fileWhitelist = ["GlobalInputMonitor"]

enum Log {
    static func info(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        file: String = #file
    ) {
        filterLog(sourceFile: file) {
            print(items, separator: separator, terminator: terminator)
        }
    }
    
    static func debug(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        file: String = #file
    ) {
        filterLog(sourceFile: file) {
            debugPrint(items, separator: separator, terminator: terminator)
        }
    }
    
    private static func filterLog(
        sourceFile: String,
        log: () -> ()
    ) {
        let fileName = URL(fileURLWithPath: sourceFile).deletingPathExtension().lastPathComponent
        if fileWhitelist.contains(fileName) {
            log()
        }
    }
}
