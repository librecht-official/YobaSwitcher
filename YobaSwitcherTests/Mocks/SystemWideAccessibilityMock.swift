//
//  SystemWideMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class SystemWideAccessibilityMock: SystemWideAccessibility {
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    private(set) lazy var _focusedElement = MethodStub<Void, FocusedUIElement?>(name: "focusedElement() -> FocusedUIElement?", testCase)
    
    func focusedElement() -> FocusedUIElement? {
        return _focusedElement.callWithOptionalReturnValue(arguments: ())
    }
}

final class FocusedUIElementMock: FocusedUIElement {
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    private(set) lazy var _selectedText = PropertyStub<String>(name: "selectedText", testCase)
    
    var selectedText: String {
        get { _selectedText._value }
        set { _selectedText._value = newValue }
    }
}
