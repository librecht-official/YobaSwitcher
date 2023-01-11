//
//  Stubbing.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import XCTest

public struct PropertyStub<T> {
    public let name: StaticString
    public private(set) weak var testCase: XCTestCase?
    
    public init(name: StaticString, _ testCase: XCTestCase?) {
        self.name = name
        self.testCase = testCase
    }
    
    public private(set) var value: T?
    public private(set) var getCallCount: Int = 0
    public private(set) var setCallCount: Int = 0
    
    var _value: T {
        mutating get {
            guard let val = value else {
                testCase?.continueAfterFailure = false
                XCTFail("Uninitialized property getter (\(name)) was called. Test case: \(String(describing: testCase?.name))")
                fatalError()
            }
            getCallCount += 1
            return val
        }
        set {
            setCallCount += 1
            value = newValue
        }
    }
    
    var _optionalValue: T? {
        mutating get {
            getCallCount += 1
            return value
        }
        set {
            setCallCount += 1
            value = newValue
        }
    }
}

public struct MethodStub<Arguments, ReturnValue> {
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
    
    mutating func call(with arguments: Arguments) {
        callCount += 1
        argumentsHistory.append(arguments)
        do {
            _ = try body?(arguments)
        } catch {}
    }
    
    mutating func callWithReturnValue(with arguments: Arguments) -> ReturnValue {
        guard let returnValue = returnValue else {
            testCase?.continueAfterFailure = false
            XCTFail("Method (\(name)) was called with uninitialized return-value", file: "?")
            fatalError()
        }
        call(with: arguments)
        return returnValue
    }
    
    mutating func callWithThrow(arguments: Arguments) throws {
        if let throwValue = throwValue {
            throw throwValue
        }
        call(with: arguments)
    }
}

struct CallCount: ExpressibleByIntegerLiteral {
    let value: Int
    
    static let once = CallCount(integerLiteral: 1)
    
    static let twice = CallCount(integerLiteral: 2)

    typealias IntegerLiteralType = Int

    init(integerLiteral value: Int) {
        self.value = value
    }
}
