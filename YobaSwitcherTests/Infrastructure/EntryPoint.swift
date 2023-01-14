//
//  TestBundleEntryPoint.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 14.01.2023.
//

import XCTest
@testable import YobaSwitcher

class EntryPoint: NSObject {
    override init() {
        Log.config.logLevel = .critical
    }
}
