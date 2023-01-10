//
//  GlobalInputMonitorMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class GlobalInputMonitorMock: GlobalInputMonitorProtocol {
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    // MARK: delegate
    
    private(set) lazy var _handler = PropertyStub<GlobalInputMonitorHandler>(name: "handler", testCase)
    
    var handler: GlobalInputMonitorHandler? {
        get { _handler._optionalValue }
        set { _handler._optionalValue = newValue }
    }
    
    // MARK: start()
    
    private(set) lazy var _start = MethodStub<Void, Void>(name: "start()", testCase)
    
    func start() {
        _start.call(with: ())
    }
}
