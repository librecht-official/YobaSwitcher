//
//  SelectedTextManagerMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 12.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class SelectedTextManagerMock: SelectedTextManager {
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    private(set) lazy var _replaceSelectedTextWithAlternativeKeyboardLanguage = MethodStub<Void, Bool>(name: "replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool", testCase)
    
    func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool {
        _replaceSelectedTextWithAlternativeKeyboardLanguage.callWithReturnValue(arguments: ())
    }
}
