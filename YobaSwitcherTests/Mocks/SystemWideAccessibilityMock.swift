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
    
    func focusedElement() -> YobaSwitcher.FocusedUIElement? {
         nil
    }
}
