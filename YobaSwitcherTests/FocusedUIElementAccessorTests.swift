//
//  FocusedUIElementAccessorTests.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 15.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class FocusedUIElementAccessorTests: XCTestCase {
    var accessor: FocusedUIElementAccessor<AccessibilityUIElementMock>!
    var elementMock: AccessibilityUIElementMock!
    
    override func setUpWithError() throws {
        elementMock = AccessibilityUIElementMock(self)
        accessor = FocusedUIElementAccessor(elementMock)
    }

    func testGetSelectedText() {
        // given
        elementMock._copyAttributeValue.body = { args in
            XCTAssertEqual(args.0 as String, kAXSelectedTextAttribute)
            args.1.pointee = "Result" as CFString
            return AXError.success
        }
        // when
        let result = accessor.selectedText
        // then
        XCTAssertEqual(result, "Result")
        elementMock._copyAttributeValue.wasCalled(1)
    }
    
    func testGetSelectedText_NoSelectedText() {
        // given
        elementMock._copyAttributeValue.body = { args in
            XCTAssertEqual(args.0, kAXSelectedTextAttribute)
            return AXError.success
        }
        // when
        let result = accessor.selectedText
        // then
        XCTAssertEqual(result, "")
        elementMock._copyAttributeValue.wasCalled(1)
    }
    
    func testSetSelectedText() {
        // given
        elementMock._isAttributeSettable.body = { args in
            XCTAssertEqual(args.0, kAXSelectedTextAttribute)
            args.1.pointee = true
            return AXError.success
        }
        elementMock._setAttributeValue.body = { args in
            XCTAssertEqual(args.0, kAXSelectedTextAttribute)
            XCTAssertEqual(args.1 as? String, "New text")
            return AXError.success
        }
        // when
        accessor.selectedText = "New text"
        // then
        elementMock._isAttributeSettable.wasCalled(1)
        elementMock._setAttributeValue.wasCalled(1)
    }
    
    func testSetSelectedText_TextIsNotSettable() {
        // given
        elementMock._isAttributeSettable.body = { args in
            XCTAssertEqual(args.0, kAXSelectedTextAttribute)
            args.1.pointee = false
            return AXError.success
        }
        // when
        accessor.selectedText = "New text"
        // then
        elementMock._isAttributeSettable.wasCalled(1)
        elementMock._setAttributeValue.wasCalled(0)
    }
}
