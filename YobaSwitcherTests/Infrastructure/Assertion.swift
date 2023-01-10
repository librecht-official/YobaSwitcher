//
//  Assertion.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import XCTest

enum Assert {
    static func property<T>(_ prop: PropertyStub<T>, wasGet callCount: CallCount, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(prop.getCallCount, callCount.value, "Expected ... \(prop.name)", file: file, line: line)
    }
    
    static func property<T>(_ prop: PropertyStub<T>, wasSet callCount: CallCount, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(prop.setCallCount, callCount.value, "Expected ... \(prop.name)", file: file, line: line)
    }
    
    static func property<T: Equatable>(_ prop: PropertyStub<T>, equalTo expectedValue: T, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(prop.value, expectedValue, "Expected ...", file: file, line: line)
    }
    
    static func property<T>(_ prop: PropertyStub<T>, identicalTo expectedObject: AnyObject?, file: StaticString = #filePath, line: UInt = #line) {
        let object = prop.value as? AnyObject
        XCTAssertIdentical(object, expectedObject, "Expected ...", file: file, line: line)
    }
    
    static func method<I, O>(_ meth: MethodStub<I, O>, wasCalled callCount: CallCount, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(meth.callCount, callCount.value, "Expected ... \(meth.name)", file: file, line: line)
    }
    
    static func methodWasCalledWithArguments<I, O>(_ meth: MethodStub<I, O>, _ argumentsAssetions: (I) -> (), file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(meth.arguments, "Method \(meth.name) wasn't called as expected")
        argumentsAssetions(meth.arguments!)
    }
}
