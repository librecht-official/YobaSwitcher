//
//  VirtualKeyboardMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class VirtualKeyboardMock: VirtualKeyboardProtocol {
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    private(set) lazy var _postKeystrokeEvent = MethodStub<(KeystrokeEvent, CGEventTapProxy), Void>(name: "postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy)", testCase)
    
    func postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy) {
        _postKeystrokeEvent.call(with: (keystrokeEvent, proxy))
    }
    
    // MARK: switchInputSource()
    
    lazy var _switchInputSource = MethodStub<Void, Void>(name: "switchInputSource()", testCase)
    
    func switchInputSource() {
        _switchInputSource.call(with: ())
    }
    
    private(set) lazy var _layoutMappingForText = MethodStub<String, KeyboardLayoutMapping>(name: "layoutMapping(for text: String) -> KeyboardLayoutMapping", testCase)
    
    func layoutMapping(for text: String) -> KeyboardLayoutMapping {
        _layoutMappingForText.callWithReturnValue(arguments: text)
    }
    
    private(set) lazy var _selectedInputSource = MethodStub<Void, InputSource>(name: "selectedInputSource()", testCase)
    
    func selectedInputSource() -> InputSource {
        _selectedInputSource.callWithReturnValue(arguments: ())
    }
    
    private(set) lazy var _inputSourceForLanguageID = MethodStub<LanguageIdentifier, InputSource>(name: "inputSource(forLanguage id: LanguageIdentifier) -> InputSource", testCase)
    
    func inputSource(forLanguage id: LanguageIdentifier) -> InputSource {
        _inputSourceForLanguageID.callWithReturnValue(arguments: id)
    }
}
