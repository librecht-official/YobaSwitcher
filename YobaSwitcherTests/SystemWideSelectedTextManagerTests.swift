//
//  SystemWideSelectedTextManager.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 12.01.2023.
//

import Carbon
import XCTest
@testable import YobaSwitcher

final class SystemWideSelectedTextManagerTests: XCTestCase {
    var manager: SystemWideSelectedTextManager!
    var keyboardMock: VirtualKeyboardMock!
    var systemWideMock: SystemWideAccessibilityMock!
    var focusedUIElementMock: FocusedUIElementMock!
    
    override func setUpWithError() throws {
        keyboardMock = VirtualKeyboardMock(self)
        systemWideMock = SystemWideAccessibilityMock(self)
        focusedUIElementMock = FocusedUIElementMock(self)
        manager = SystemWideSelectedTextManager(keyboard: keyboardMock, systemWide: systemWideMock)
        
        systemWideMock._focusedElement.returnValue = focusedUIElementMock
    }

    func testSwitchingSelectedTextLanguage_EnglishText_EnInputSource() {
        // given
        focusedUIElementMock._selectedText.stubValue = TestData.engText
        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.enToRu
        keyboardMock._inputSourceForLanguageId.returnValue = TestData.enInputSource
        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.enInputSource

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()
        
        // then
        XCTAssertTrue(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(1)
            .wasSet(1)
            .equalTo(TestData.rusText)
        keyboardMock._layoutMappingForText
            .wasCalled(1, withArguments: TestData.engText)
        keyboardMock._inputSourceForLanguageId
            .wasCalled(1, withArguments: KeyboardLayoutMapping.enToRu.targetLanguage)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
        keyboardMock._switchInputSource.wasCalled(0)
    }
    
    func testSwitchingSelectedTextLanguage_EnglishText_RuInputSource() {
        // given
        focusedUIElementMock._selectedText.stubValue = TestData.engText
        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.enToRu
        keyboardMock._inputSourceForLanguageId.returnValue = TestData.enInputSource
        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.ruInputSource

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()

        // then
        XCTAssertTrue(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(1)
            .wasSet(1)
            .equalTo(TestData.rusText)
        keyboardMock._layoutMappingForText
            .wasCalled(1, withArguments: TestData.engText)
        keyboardMock._inputSourceForLanguageId
            .wasCalled(1, withArguments: KeyboardLayoutMapping.enToRu.targetLanguage)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
        keyboardMock._switchInputSource.wasCalled(1)
    }
    
    func testSwitchingSelectedTextLanguage_RussianText_RuInputSource() {
        // given
        focusedUIElementMock._selectedText.stubValue = TestData.rusText
        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.ruToEn
        keyboardMock._inputSourceForLanguageId.returnValue = TestData.ruInputSource
        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.ruInputSource

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()

        // then
        XCTAssertTrue(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(1)
            .wasSet(1)
            .equalTo(TestData.engText)
        keyboardMock._layoutMappingForText
            .wasCalled(1, withArguments: TestData.rusText)
        keyboardMock._inputSourceForLanguageId
            .wasCalled(1, withArguments: KeyboardLayoutMapping.ruToEn.targetLanguage)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
        keyboardMock._switchInputSource.wasCalled(0)
    }
    
    func testSwitchingSelectedTextLanguage_RussianText_EnInputSource() {
        // given
        focusedUIElementMock._selectedText.stubValue = TestData.rusText
        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.ruToEn
        keyboardMock._inputSourceForLanguageId.returnValue = TestData.ruInputSource
        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.enInputSource

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()

        // then
        XCTAssertTrue(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(1)
            .wasSet(1)
            .equalTo(TestData.engText)
        keyboardMock._layoutMappingForText
            .wasCalled(1, withArguments: TestData.rusText)
        keyboardMock._inputSourceForLanguageId
            .wasCalled(1, withArguments: KeyboardLayoutMapping.ruToEn.targetLanguage)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
        keyboardMock._switchInputSource.wasCalled(1)
    }
    
    func testSwitchingSelectedTextLanguage_NoSelectedText() {
        // given
        focusedUIElementMock._selectedText.stubValue = ""

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()

        // then
        XCTAssertFalse(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(1)
            .wasSet(0)
        keyboardMock._layoutMappingForText.wasCalled(0)
        keyboardMock._inputSourceForLanguageId.wasCalled(0)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(0)
        keyboardMock._switchInputSource.wasCalled(0)
    }
    
    func testSwitchingSelectedTextLanguage_NoFocusedUIElement() {
        // given
        systemWideMock._focusedElement.returnValue = nil

        // when
        let result = manager.replaceSelectedTextWithAlternativeKeyboardLanguage()

        // then
        XCTAssertFalse(result)
        systemWideMock._focusedElement.wasCalled(1)
        focusedUIElementMock._selectedText
            .wasGot(0)
            .wasSet(0)
        keyboardMock._layoutMappingForText.wasCalled(0)
        keyboardMock._inputSourceForLanguageId.wasCalled(0)
        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(0)
        keyboardMock._switchInputSource.wasCalled(0)
    }
}

enum TestData {
    static let enInputSource = InputSource(TISCopyInputSourceForLanguage("en" as CFString).takeRetainedValue())
    static let ruInputSource = InputSource(TISCopyInputSourceForLanguage("ru" as CFString).takeRetainedValue())
    
    static let engText = #"§1234567890-=qwertyuiop[]asdfghjkl;'\zxcvbnm,./ ±!@#$%^&*{}:"|~`<>?"#
    static let rusText = #">1234567890-=йцукенгшщзхъфывапролджэёячсмитьбю/ <!"№%:,.;ХЪЖЭЁ[]БЮ?"#
}
