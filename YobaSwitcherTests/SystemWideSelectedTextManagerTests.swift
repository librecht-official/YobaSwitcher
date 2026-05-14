////
////  SystemWideSelectedTextManager.swift
////  YobaSwitcherTests
////
////  Created by Vladislav Librecht on 12.01.2023.
////
//
//import Carbon
//import XCTest
//@testable import YobaSwitcher
//
//final class SystemWideSelectedTextManagerTests: XCTestCase {
//    var manager: SystemWideSelectedTextManager!
//    var keyboardMock: VirtualKeyboardMock!
//    var systemWideMock: SystemWideAccessibilityMock!
//    var focusedUIElementMock: FocusedUIElementMock!
//    
//    override func setUpWithError() throws {
//        keyboardMock = VirtualKeyboardMock(self)
//        systemWideMock = SystemWideAccessibilityMock(self)
//        focusedUIElementMock = FocusedUIElementMock(self)
//        manager = SystemWideSelectedTextManager(keyboard: keyboardMock, systemWide: systemWideMock)
//        
//        systemWideMock._focusedElement.returnValue = focusedUIElementMock
//    }
//    
//    // MARK: - replaceSelectedTextWithAlternativeKeyboardLayout
//
//    func testSwitchingSelectedTextLanguage_EngCharacters_EnInputSource() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.engCharacters
//        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.enToRu
//        keyboardMock._inputSourceForLanguageId.returnValue = TestData.enInputSource
//        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.enInputSource
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//        
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.rusCharacters)
//        keyboardMock._layoutMappingForText
//            .wasCalled(1, withArguments: TestData.engCharacters)
//        keyboardMock._inputSourceForLanguageId
//            .wasCalled(1, withArguments: KeyboardLayoutMapping.enToRu.targetLanguage)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
//        keyboardMock._switchInputSource.wasCalled(0)
//    }
//    
//    func testSwitchingSelectedTextLanguage_EngCharacters_RuInputSource() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.engCharacters
//        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.enToRu
//        keyboardMock._inputSourceForLanguageId.returnValue = TestData.enInputSource
//        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.ruInputSource
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.rusCharacters)
//        keyboardMock._layoutMappingForText
//            .wasCalled(1, withArguments: TestData.engCharacters)
//        keyboardMock._inputSourceForLanguageId
//            .wasCalled(1, withArguments: KeyboardLayoutMapping.enToRu.targetLanguage)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
//        keyboardMock._switchInputSource.wasCalled(1)
//    }
//    
//    func testSwitchingSelectedTextLanguage_RusCharacters_RuInputSource() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.rusCharacters
//        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.ruToEn
//        keyboardMock._inputSourceForLanguageId.returnValue = TestData.ruInputSource
//        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.ruInputSource
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.engCharacters)
//        keyboardMock._layoutMappingForText
//            .wasCalled(1, withArguments: TestData.rusCharacters)
//        keyboardMock._inputSourceForLanguageId
//            .wasCalled(1, withArguments: KeyboardLayoutMapping.ruToEn.targetLanguage)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
//        keyboardMock._switchInputSource.wasCalled(0)
//    }
//    
//    func testSwitchingSelectedTextLanguage_RusCharacters_EnInputSource() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.rusCharacters
//        keyboardMock._layoutMappingForText.returnValue = KeyboardLayoutMapping.ruToEn
//        keyboardMock._inputSourceForLanguageId.returnValue = TestData.ruInputSource
//        keyboardMock._currentKeyboardLayoutInputSource.returnValue = TestData.enInputSource
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.engCharacters)
//        keyboardMock._layoutMappingForText
//            .wasCalled(1, withArguments: TestData.rusCharacters)
//        keyboardMock._inputSourceForLanguageId
//            .wasCalled(1, withArguments: KeyboardLayoutMapping.ruToEn.targetLanguage)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(1)
//        keyboardMock._switchInputSource.wasCalled(1)
//    }
//    
//    func testSwitchingSelectedTextLanguage_NoSelectedText() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = ""
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//
//        // then
//        XCTAssertFalse(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(0)
//        keyboardMock._layoutMappingForText.wasCalled(0)
//        keyboardMock._inputSourceForLanguageId.wasCalled(0)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(0)
//        keyboardMock._switchInputSource.wasCalled(0)
//    }
//    
//    func testSwitchingSelectedTextLanguage_NoFocusedUIElement() {
//        // given
//        systemWideMock._focusedElement.returnValue = nil
//
//        // when
//        let result = manager.replaceSelectedTextWithAlternativeKeyboardLayout()
//
//        // then
//        XCTAssertFalse(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(0)
//            .wasSet(0)
//        keyboardMock._layoutMappingForText.wasCalled(0)
//        keyboardMock._inputSourceForLanguageId.wasCalled(0)
//        keyboardMock._currentKeyboardLayoutInputSource.wasCalled(0)
//        keyboardMock._switchInputSource.wasCalled(0)
//    }
//    
//    // MARK: - changeSelectedTextCase
//    
//    /// Should convert lowercased text to uppercased
//    func testSwitchingSelectedTextCase_Alphanumerics() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.alphanumerics
//        
//        // when
//        let result = manager.changeSelectedTextCase()
//        
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.alphanumerics.uppercased())
//    }
//    
//    /// Should convert uppercased text to lowercased
//    func testSwitchingSelectedTextCase_UppercasedAlphanumerics() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.alphanumerics.uppercased()
//        
//        // when
//        let result = manager.changeSelectedTextCase()
//        
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.alphanumerics)
//    }
//    
//    /// Should convert text with mixed cased characters to uppercased text
//    func testSwitchingSelectedTextCase_Mixcased() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = TestData.mixcased
//        
//        // when
//        let result = manager.changeSelectedTextCase()
//        
//        // then
//        XCTAssertTrue(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(1)
//            .equalTo(TestData.mixcased.uppercased())
//    }
//    
//    func testSwitchingSelectedTextCase_NoSelectedText() {
//        // given
//        focusedUIElementMock._selectedText.stubValue = ""
//        
//        // when
//        let result = manager.changeSelectedTextCase()
//        
//        // then
//        XCTAssertFalse(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(1)
//            .wasSet(0)
//    }
//    
//    func testSwitchingSelectedTextCase_NoFocusedElement() {
//        // given
//        systemWideMock._focusedElement.returnValue = nil
//        
//        // when
//        let result = manager.changeSelectedTextCase()
//        
//        // then
//        XCTAssertFalse(result)
//        systemWideMock._focusedElement.wasCalled(1)
//        focusedUIElementMock._selectedText
//            .wasGot(0)
//            .wasSet(0)
//    }
//}
//
//private enum TestData {
//    static let enInputSource = TextInputSource(TISCopyInputSourceForLanguage("en" as CFString).takeRetainedValue())
//    static let ruInputSource = TextInputSource(TISCopyInputSourceForLanguage("ru" as CFString).takeRetainedValue())
//    
//    static let engCharacters    = #"§1234567890-=qwertyuiop[]asdfghjkl;'\zxcvbnm,./ ±!@#$%^&*{}:"|~`<>?"#
//    static let rusCharacters    = #">1234567890-=йцукенгшщзхъфывапролджэёячсмитьбю/ <!"№%:,.;ХЪЖЭЁ[]БЮ?"#
//    static let engLetters       = "qwertyuiopasdfghjklzxcvbnm"
//    static let rusLetters       = "йцукенгшщзхъфывапролджэёячсмитьбю"
//    static let numerics         = "1234567890"
//    static let alphanumerics    = numerics + engLetters + rusLetters
//    static let engTextMixcased  = "Eng TeXt"
//    static let rusTextMixcased  = "Рус ТеКСт"
//    static let mixcased         = engTextMixcased + rusTextMixcased
//}
