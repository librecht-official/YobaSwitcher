// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import XCTest
@testable import YobaSwitcher

open class AccessibilityUIElementMock: AccessibilityUIElement {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
    }

    // MARK: systemWide

    public private(set) static var _systemWide = PropertyStub<AccessibilityUIElement>(name: "systemWide", testCase)

    public static var systemWide: AccessibilityUIElement {
        _systemWide._value
    }

    public private(set) lazy var _copyAttributeValue = MethodStub<(String, UnsafeMutablePointer<CFTypeRef?>), AXError>(name: "copyAttributeValue(_:_:)", testCase)

    @discardableResult
    public func copyAttributeValue(_ attribute: String, _ value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        _copyAttributeValue.callWithReturnValue(arguments: (attribute, value))
    }

    public private(set) lazy var _isAttributeSettable = MethodStub<(String, UnsafeMutablePointer<DarwinBoolean>), AXError>(name: "isAttributeSettable(_:_:)", testCase)

    @discardableResult
    public func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError {
        _isAttributeSettable.callWithReturnValue(arguments: (attribute, settable))
    }

    public private(set) lazy var _setAttributeValue = MethodStub<(String, CFTypeRef), AXError>(name: "setAttributeValue(_:_:)", testCase)

    @discardableResult
    public func setAttributeValue(_ attribute: String, _ value: CFTypeRef) -> AXError {
        _setAttributeValue.callWithReturnValue(arguments: (attribute, value))
    }

    static func resetState() {
        _systemWide.reset()
    }
}

// MARK: -

open class FocusedUIElementMock: FocusedUIElement {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
    }

    // MARK: selectedText

    public private(set) lazy var _selectedText = PropertyStub<String>(name: "selectedText", testCase)

    public var selectedText: String {
        get { _selectedText._value }
        set { _selectedText._value = newValue }
    }

    static func resetState() {
    }
}

// MARK: -

open class GlobalInputMonitorMock: GlobalInputMonitorProtocol {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
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

    static func resetState() {
    }
}

// MARK: -

open class SelectedTextManagerMock: SelectedTextManager {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
    }

    public private(set) lazy var _replaceSelectedTextWithAlternativeKeyboardLanguage = MethodStub<(), Bool>(name: "replaceSelectedTextWithAlternativeKeyboardLanguage", testCase)

    @discardableResult
    public func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool {
        _replaceSelectedTextWithAlternativeKeyboardLanguage.callWithReturnValue(arguments: ())
    }

    public private(set) lazy var _changeSelectedTextCase = MethodStub<(), Bool>(name: "changeSelectedTextCase", testCase)

    @discardableResult
    public func changeSelectedTextCase() -> Bool {
        _changeSelectedTextCase.callWithReturnValue(arguments: ())
    }

    static func resetState() {
    }
}

// MARK: -

open class SystemWideAccessibilityMock: SystemWideAccessibility {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
    }

    public private(set) lazy var _focusedElement = MethodStub<(), FocusedUIElement?>(name: "focusedElement", testCase)

    public func focusedElement() -> FocusedUIElement? {
        _focusedElement.callWithOptionalReturnValue(arguments: ())
    }

    static func resetState() {
    }
}

// MARK: -

open class VirtualKeyboardMock: VirtualKeyboardProtocol {
    public let id: String?
    public static weak var testCase: XCTestCase?
    public private(set) weak var testCase: XCTestCase?

    public init(_ testCase: XCTestCase, id: String? = nil) {
        self.testCase = testCase
        self.id = id
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

    static func resetState() {
    }
}

// MARK: -
