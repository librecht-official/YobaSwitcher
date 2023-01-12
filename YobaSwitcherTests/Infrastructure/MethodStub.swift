//
//  MethodStub.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import XCTest

public final class MethodStub<Arguments, ReturnValue> {
    public let name: StaticString
    public private(set) weak var testCase: XCTestCase?
    
    public init(name: StaticString, _ testCase: XCTestCase?) {
        self.name = name
        self.testCase = testCase
    }
    
    public private(set) var argumentsHistory: [Arguments] = []
    
    public var arguments: Arguments? {
        argumentsHistory.last
    }
    
    public private(set) var callCount: Int = 0
    
    public var returnValue: ReturnValue?
    
    public var body: ((Arguments) throws -> ReturnValue)?
    
    public var throwValue: Error?
    
    func call(with arguments: Arguments) {
        callCount += 1
        argumentsHistory.append(arguments)
        do {
            _ = try body?(arguments)
        } catch {}
    }
    
    func callWithReturnValue(arguments: Arguments, filePath: StaticString = #filePath, line: UInt = #line) -> ReturnValue {
        guard let returnValue = returnValue else {
            testCase?.continueAfterFailure = false
            XCTFail("Method `\(name)` was called with uninitialized return-value", file: filePath, line: line)
            fatalError()
        }
        call(with: arguments)
        return returnValue
    }
    
    func callWithOptionalReturnValue<T>(arguments: Arguments, filePath: StaticString = #filePath, line: UInt = #line) -> ReturnValue where T? == ReturnValue {
        call(with: arguments)
        return returnValue?.flatMap { $0 }
    }
    
    func callWithThrow(arguments: Arguments) throws {
        if let throwValue = throwValue {
            throw throwValue
        }
        call(with: arguments)
    }
}

// MARK: - Asserting

extension MethodStub {
    @discardableResult
    func wasCalled(_ expectedCallCount: CallCount, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(callCount, expectedCallCount.value, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount.value)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func wasCalled(_ expectedCallCount: CallCount, withArguments expectedArguments: Arguments, file: StaticString = #filePath, line: UInt = #line) -> Self where Arguments: Equatable {
        XCTAssertEqual(callCount, expectedCallCount.value, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount.value)", file: file, line: line)
        if let arguments = arguments {
            XCTAssertEqual(arguments, expectedArguments, file: file, line: line)
        } else {
            XCTFail("Method \(name) wasn't called as expected", file: file, line: line)
        }
        return self
    }
    
    @discardableResult
    func wasCalled(_ expectedCallCount: CallCount, withArguments argumentsAssetions: (Arguments) -> (), file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(callCount, expectedCallCount.value, "Method \(name) was called \(callCount) times, expected: \(expectedCallCount.value)", file: file, line: line)
        if let arguments = arguments {
            argumentsAssetions(arguments)
        } else {
            XCTFail("Method \(name) wasn't called as expected", file: file, line: line)
        }
        return self
    }
}
