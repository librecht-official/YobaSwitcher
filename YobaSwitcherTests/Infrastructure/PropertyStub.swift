//
//  Stubbing.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import XCTest

public final class PropertyStub<T> {
    public let name: StaticString
    public private(set) weak var testCase: XCTestCase?
    
    public init(name: StaticString, _ testCase: XCTestCase?) {
        self.name = name
        self.testCase = testCase
    }
    
    public var stubValue: T? {
        get {
            stubValuesHistory.last ?? nil
        }
        set {
            stubValuesHistory.append(newValue)
        }
    }
    private var stubValuesHistory: [T?] = []
    public private(set) var getCallCount: Int = 0
    public private(set) var setCallCount: Int = 0
    
    var _value: T {
        get {
            guard let val = stubValue else {
                testCase?.continueAfterFailure = false
                XCTFail("Uninitialized property getter (\(name)) was called. Test case: \(String(describing: testCase?.name))")
                fatalError()
            }
            getCallCount += 1
            return val
        }
        set {
            setCallCount += 1
            stubValue = newValue
        }
    }
    
    var _optionalValue: T? {
        get {
            getCallCount += 1
            return stubValue
        }
        set {
            setCallCount += 1
            stubValue = newValue
        }
    }
}

// MARK: - Asserting

extension PropertyStub {
    @discardableResult
    func wasGot(_ expectedCallCount: CallCount, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(getCallCount, expectedCallCount.value, "Property \(name) was got \(getCallCount) times, expected: \(expectedCallCount.value)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func wasSet(_ expectedCallCount: CallCount, file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssertEqual(setCallCount, expectedCallCount.value, "Property \(name) was set \(setCallCount) times, expected: \(expectedCallCount.value)", file: file, line: line)
        return self
    }
    
    @discardableResult
    func equalTo(_ expectedValue: T, file: StaticString = #filePath, line: UInt = #line) -> Self where T: Equatable {
        XCTAssertEqual(stubValue, expectedValue, "Property \(name) value is different from expected", file: file, line: line)
        return self
    }
}
