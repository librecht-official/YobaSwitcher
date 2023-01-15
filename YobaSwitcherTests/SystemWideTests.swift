//
//  SystemWideTests.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 15.01.2023.
//

import XCTest
import SnapshotTesting
@testable import YobaSwitcher

final class SystemWideTests: XCTestCase {
    var systemWide: SystemWide<AccessibilityUIElementMock>!
    var innerSystemWideMock: AccessibilityUIElementMock!
    var focusedElementMock: AccessibilityUIElementMock!
    
    override class func setUp() {
        SnapshotTesting.isRecording = false
    }
    
    override func setUpWithError() throws {
        innerSystemWideMock = AccessibilityUIElementMock(self)
        AccessibilityUIElementMock._systemWide.stubValue = innerSystemWideMock
        focusedElementMock = AccessibilityUIElementMock(self, id: "focusedElementMock")
        systemWide = SystemWide<AccessibilityUIElementMock>()
    }
    
    override func tearDown() {
        AccessibilityUIElementMock.resetState()
    }

    func testFocusedElement() {
        // given
        innerSystemWideMock._copyAttributeValue.body = { [focusedElementMock] args in
            XCTAssertEqual(args.0, kAXFocusedUIElementAttribute)
            args.1.pointee = focusedElementMock
            return AXError.success
        }

        // when
        let result = systemWide.focusedElement()
        
        // then
        assertSnapshot(matching: result, as: .dump, named: "result")
        innerSystemWideMock._copyAttributeValue.wasCalled(1)
    }
    
    func testFocusedElement_IncorrectElementType() {
        // given
        innerSystemWideMock._copyAttributeValue.body = { args in
            XCTAssertEqual(args.0, kAXFocusedUIElementAttribute)
            args.1.pointee = "" as AnyObject
            return AXError.success
        }
        
        // when
        let result = systemWide.focusedElement()
        
        // then
        XCTAssertNil(result)
        innerSystemWideMock._copyAttributeValue.wasCalled(1)
    }
}
