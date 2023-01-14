// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import XCTest
@testable import YobaSwitcher

open class FocusedUIElementMock: FocusedUIElement {
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
  
    // MARK: selectedText

    public private(set) lazy var _selectedText = PropertyStub<String>(name: "selectedText", testCase)

    public var selectedText: String {
        get { _selectedText._value }
        set { _selectedText._value = newValue }
    }

}

// MARK: -

open class GlobalInputMonitorMock: GlobalInputMonitorProtocol {
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
  
    // MARK: handler

    public private(set) lazy var _handler = PropertyStub<GlobalInputMonitorHandler>(name: "handler", testCase)

    public var handler: GlobalInputMonitorHandler? {
        get { _handler._optionalValue }
        set { _handler._optionalValue = newValue }
    }

    public private(set) lazy var _start = MethodStub<(), Void>(name: "start", testCase)

    public func start() -> Void {
        _start.call(with: ())
    }

}

// MARK: -

open class SelectedTextManagerMock: SelectedTextManager {
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }

    public private(set) lazy var _replaceSelectedTextWithAlternativeKeyboardLanguage = MethodStub<(), Bool>(name: "replaceSelectedTextWithAlternativeKeyboardLanguage", testCase)

    @discardableResult
    public func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool {
        _replaceSelectedTextWithAlternativeKeyboardLanguage.callWithReturnValue(arguments: ())
    }

}

// MARK: -

open class SystemWideAccessibilityMock: SystemWideAccessibility {
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }

    public private(set) lazy var _focusedElement = MethodStub<(), FocusedUIElement?>(name: "focusedElement", testCase)

    public func focusedElement() -> FocusedUIElement? {
        _focusedElement.callWithOptionalReturnValue(arguments: ())
    }

}

// MARK: -

open class VirtualKeyboardMock: VirtualKeyboardProtocol {
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }

    public private(set) lazy var _postInputEvent = MethodStub<(InputEvent, CGEventTapProxy), Void>(name: "postInputEvent(_:_:)", testCase)

    public func postInputEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) -> Void {
        _postInputEvent.call(with: (inputEvent, proxy))
    }

    public private(set) lazy var _layoutMappingForText = MethodStub<String, KeyboardLayoutMapping>(name: "layoutMapping(for:)", testCase)

    public func layoutMapping(for text: String) -> KeyboardLayoutMapping {
        _layoutMappingForText.callWithReturnValue(arguments: text)
    }

    public private(set) lazy var _currentKeyboardLayoutInputSource = MethodStub<(), InputSource>(name: "currentKeyboardLayoutInputSource", testCase)

    public func currentKeyboardLayoutInputSource() -> InputSource {
        _currentKeyboardLayoutInputSource.callWithReturnValue(arguments: ())
    }

    public private(set) lazy var _inputSourceForLanguageId = MethodStub<LanguageIdentifier, InputSource>(name: "inputSource(forLanguage:)", testCase)

    public func inputSource(forLanguage id: LanguageIdentifier) -> InputSource {
        _inputSourceForLanguageId.callWithReturnValue(arguments: id)
    }

    public private(set) lazy var _switchInputSource = MethodStub<(), Void>(name: "switchInputSource", testCase)

    public func switchInputSource() -> Void {
        _switchInputSource.call(with: ())
    }

    public private(set) lazy var _switchInputSourceCompletion = MethodStub<() -> (), Void>(name: "switchInputSource(completion:)", testCase)

    public func switchInputSource(completion: @escaping () -> ()) -> Void {
        _switchInputSourceCompletion.call(with: completion)
    }

}

// MARK: -
