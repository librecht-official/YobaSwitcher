//// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
//// DO NOT EDIT
//
//// swiftlint:disable line_length
//// swiftlint:disable variable_name
//
//import XCTest
//@testable import YobaSwitcher
//
////open class AccessibilityUIElementMock: AccessibilityUIElement {
////    public let _mockId: String?
////    public static weak var testCase: XCTestCase?
////    public private(set) weak var testCase: XCTestCase?
////
////    public init(_ testCase: XCTestCase, id: String? = nil) {
////        self.testCase = testCase
////        self._mockId = id
////    }
////
////    // MARK: systemWide
////
////    public private(set) static var _systemWide = PropertyStub<AccessibilityUIElement>(name: "systemWide", testCase)
////
////    public static var systemWide: AccessibilityUIElement {
////        _systemWide._value
////    }
////
////    public private(set) lazy var _copyAttributeValue = MethodStub<(String, UnsafeMutablePointer<CFTypeRef?>), AXError>(name: "copyAttributeValue(_:_:)", testCase)
////
////    @discardableResult
////    public func copyAttributeValue(_ attribute: String, _ value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
////        _copyAttributeValue.callWithReturnValue(arguments: (attribute, value))
////    }
////
////    public private(set) lazy var _isAttributeSettable = MethodStub<(String, UnsafeMutablePointer<DarwinBoolean>), AXError>(name: "isAttributeSettable(_:_:)", testCase)
////
////    @discardableResult
////    public func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError {
////        _isAttributeSettable.callWithReturnValue(arguments: (attribute, settable))
////    }
////
////    public private(set) lazy var _setAttributeValue = MethodStub<(String, CFTypeRef), AXError>(name: "setAttributeValue(_:_:)", testCase)
////
////    @discardableResult
////    public func setAttributeValue(_ attribute: String, _ value: CFTypeRef) -> AXError {
////        _setAttributeValue.callWithReturnValue(arguments: (attribute, value))
////    }
////
////    static func resetState() {
////        _systemWide.reset()
////    }
////}
//
//// MARK: -
//
//open class CoreGraphicsEventMock: CoreGraphicsEvent {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    public private(set) static var _fromInputEvent = MethodStub<InputEvent, CoreGraphicsEventMock?>(name: "fromInputEvent(_:)", testCase)
//
//    public static func fromInputEvent(_ inputEvent: InputEvent) -> Self? {
//        _fromInputEvent.callWithOptionalReturnValue(arguments: inputEvent) as? Self
//    }
//
//    public private(set) lazy var _tapPostEvent = MethodStub<CGEventTapProxy?, Void>(name: "tapPostEvent(_:)", testCase)
//
//    public func tapPostEvent(_ proxy: CGEventTapProxy?) -> Void {
//        _tapPostEvent.call(with: proxy)
//    }
//
//    static func resetState() {
//        _fromInputEvent.reset()
//    }
//}
//
//// MARK: -
//
////open class DistributedNotificationCenterMock: DistributedNotificationCenterProtocol {
////    public let _mockId: String?
////    public static weak var testCase: XCTestCase?
////    public private(set) weak var testCase: XCTestCase?
////
////    public init(_ testCase: XCTestCase, id: String? = nil) {
////        self.testCase = testCase
////        self._mockId = id
////    }
////
////    public private(set) lazy var _addObserver = MethodStub<(NSNotification.Name?, Any?, OperationQueue?, (Notification) -> Void), NSObjectProtocol>(name: "addObserver(forName:object:queue:using:)", testCase)
////
////    public func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
////        _addObserver.callWithReturnValue(arguments: (name, obj, queue, block))
////    }
////
////    public private(set) lazy var _removeObserver = MethodStub<(Any, NSNotification.Name?, String?), Void>(name: "removeObserver(_:name:object:)", testCase)
////
////    public func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: String?) -> Void {
////        _removeObserver.call(with: (observer, aName, anObject))
////    }
////
////    static func resetState() {
////    }
////}
//
//// MARK: -
//
//open class FocusedUIElementMock: FocusedUIElement {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    // MARK: selectedText
//
//    public private(set) lazy var _selectedText = PropertyStub<String>(name: "selectedText", testCase)
//
//    public var selectedText: String {
//        get { _selectedText._value }
//        set { _selectedText._value = newValue }
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
//
//open class GlobalInputMonitorMock: GlobalInputMonitorProtocol {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    // MARK: handler
//
//    public private(set) lazy var _handler = PropertyStub<GlobalInputHandler>(name: "handler", testCase)
//
//    public var handler: GlobalInputHandler? {
//        get { _handler._optionalValue }
//        set { _handler._optionalValue = newValue }
//    }
//
//    public private(set) lazy var _start = MethodStub<(), Void>(name: "start", testCase)
//
//    public func start() -> Void {
//        _start.call(with: ())
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
//
//open class SelectedTextManagerMock: SelectedTextManager {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    public private(set) lazy var _replaceSelectedTextWithAlternativeKeyboardLayout = MethodStub<(), Bool>(name: "replaceSelectedTextWithAlternativeKeyboardLayout", testCase)
//
//    @discardableResult
//    public func replaceSelectedTextWithAlternativeKeyboardLayout() -> Bool {
//        _replaceSelectedTextWithAlternativeKeyboardLayout.callWithReturnValue(arguments: ())
//    }
//
//    public private(set) lazy var _changeSelectedTextCase = MethodStub<(), Bool>(name: "changeSelectedTextCase", testCase)
//
//    @discardableResult
//    public func changeSelectedTextCase() -> Bool {
//        _changeSelectedTextCase.callWithReturnValue(arguments: ())
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
//
//open class SystemWideAccessibilityMock: SystemWideAccessibility {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    public private(set) lazy var _focusedElement = MethodStub<(), FocusedUIElement?>(name: "focusedElement", testCase)
//
//    public func focusedElement() -> FocusedUIElement? {
//        _focusedElement.callWithOptionalReturnValue(arguments: ())
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
//
//open class TextInputSourceManagerMock: TextInputSourceManager {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    public private(set) lazy var _currentKeyboardLayoutInputSource = MethodStub<(), TextInputSource>(name: "currentKeyboardLayoutInputSource", testCase)
//
//    public func currentKeyboardLayoutInputSource() -> TextInputSource {
//        _currentKeyboardLayoutInputSource.callWithReturnValue(arguments: ())
//    }
//
//    public private(set) lazy var _inputSource = MethodStub<String, TextInputSource>(name: "inputSource(forLanguage:)", testCase)
//
//    public func inputSource(forLanguage id: String) -> TextInputSource {
//        _inputSource.callWithReturnValue(arguments: id)
//    }
//
//    public private(set) lazy var _inputSourceList = MethodStub<[CFString: Any], [TextInputSource]>(name: "inputSourceList(filter:)", testCase)
//
//    public func inputSourceList(filter: [CFString: Any]) -> [TextInputSource] {
//        _inputSourceList.callWithReturnValue(arguments: filter)
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
//
//open class VirtualKeyboardMock: VirtualKeyboardProtocol {
//    public let _mockId: String?
//    public static weak var testCase: XCTestCase?
//    public private(set) weak var testCase: XCTestCase?
//
//    public init(_ testCase: XCTestCase, id: String? = nil) {
//        self.testCase = testCase
//        self._mockId = id
//    }
//
//    public private(set) lazy var _postInputEvent = MethodStub<(InputEvent, CGEventTapProxy), Void>(name: "postInputEvent(_:_:)", testCase)
//
//    public func postInputEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) -> Void {
//        _postInputEvent.call(with: (inputEvent, proxy))
//    }
//
//    public private(set) lazy var _layoutMappingForText = MethodStub<String, KeyboardLayoutMapping>(name: "layoutMapping(for:)", testCase)
//
//    public func layoutMapping(for text: String) -> KeyboardLayoutMapping {
//        _layoutMappingForText.callWithReturnValue(arguments: text)
//    }
//
//    public private(set) lazy var _currentKeyboardLayoutInputSource = MethodStub<(), TextInputSource>(name: "currentKeyboardLayoutInputSource", testCase)
//
//    public func currentKeyboardLayoutInputSource() -> TextInputSource {
//        _currentKeyboardLayoutInputSource.callWithReturnValue(arguments: ())
//    }
//
//    public private(set) lazy var _inputSourceForLanguageId = MethodStub<LanguageIdentifier, TextInputSource>(name: "inputSource(forLanguage:)", testCase)
//
//    public func inputSource(forLanguage id: LanguageIdentifier) -> TextInputSource {
//        _inputSourceForLanguageId.callWithReturnValue(arguments: id)
//    }
//
//    public private(set) lazy var _switchInputSource = MethodStub<(), Void>(name: "switchInputSource", testCase)
//
//    public func switchInputSource() -> Void {
//        _switchInputSource.call(with: ())
//    }
//
//    public private(set) lazy var _switchInputSourceCompletion = MethodStub<() -> (), Void>(name: "switchInputSource(completion:)", testCase)
//
//    public func switchInputSource(completion: @escaping () -> ()) -> Void {
//        _switchInputSourceCompletion.call(with: completion)
//    }
//
//    static func resetState() {
//    }
//}
//
//// MARK: -
