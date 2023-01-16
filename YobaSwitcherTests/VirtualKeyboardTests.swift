//
//  VirtualKeyboardTests.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 17.01.2023.
//

import Carbon
import XCTest
@testable import YobaSwitcher

final class VirtualKeyboardTests: XCTestCase {
    var keyboard: VirtualKeyboard<CoreGraphicsEventMock>!
    var notificationCenterMock: DistributedNotificationCenterMock!
    var cgEventMock: CoreGraphicsEventMock!
    
    override func setUpWithError() throws {
        cgEventMock = CoreGraphicsEventMock(self)
        notificationCenterMock = DistributedNotificationCenterMock(self)
        keyboard = VirtualKeyboard(distributedNotificationCenter: notificationCenterMock)
    }
    
    // MARK: - postInputEvent
    
    func testPostInputEvent() {
        // given
        CoreGraphicsEventMock._fromInputEvent.returnValue = cgEventMock
        // when
        keyboard.postInputEvent(TestData.inputEvent, TestData.eventProxy)
        // then
        cgEventMock._tapPostEvent.wasCalled(1, withArguments: TestData.eventProxy)
    }
    
    // MARK: - layoutMapping
    
    func testLayoutMapping_EnToRu() {
        let mapping = keyboard.layoutMapping(for: TestData.engText)
        XCTAssertEqual(mapping, KeyboardLayoutMapping.enToRu)
    }
    
    func testLayoutMapping_RuToEn() {
        let mapping = keyboard.layoutMapping(for: TestData.rusText)
        XCTAssertEqual(mapping, KeyboardLayoutMapping.ruToEn)
    }
    
    func testLayoutMapping_EmptyText() {
        let mapping = keyboard.layoutMapping(for: "")
        XCTAssertEqual(mapping, KeyboardLayoutMapping.enToRu)
    }
    
    // MARK: - currentKeyboardLayoutInputSource
    
    func testCurrentKeyboardLayoutInputSource() {
        let result = keyboard.currentKeyboardLayoutInputSource()
        XCTAssertEqual(result, TextInputSource.currentKeyboardLayoutInputSource())
    }
    
    // MARK: - inputSource(forLanguage:)
    
    func testInputSourceForLanguageId() {
        let result = keyboard.inputSource(forLanguage: .en)
        XCTAssertEqual(result, TextInputSource.inputSourceForLanguage(id: "en"))
    }
    
    // MARK: - switchInputSource
    
    func testSwitchInputSource_EnToRu() {
        // given
        TextInputSource.inputSourceForLanguage(id: "en").select()
        
        let completion = expectation(description: "completion")
        let tokenMock = NSObject()
        notificationCenterMock._addObserver.body = { args in
            let block = args.3
            OperationQueue.main.addOperation {
                block(Notification(name: .selectedKeyboardInputSourceChanged))
            }
            return tokenMock
        }
        // when
        keyboard.switchInputSource {
            completion.fulfill()
        }
        // then
        wait(for: [completion], timeout: 1)
        
        XCTAssertEqual(TextInputSource.currentKeyboardLayoutInputSource(), TextInputSource.inputSourceForLanguage(id: "ru"))
        notificationCenterMock._addObserver.wasCalled(1) { args in
            let (name, observer, queue, _) = args
            XCTAssertEqual(name, NSNotification.Name.selectedKeyboardInputSourceChanged)
            XCTAssertNil(observer)
            XCTAssertIdentical(queue, OperationQueue.main)
        }
        notificationCenterMock._removeObserver.wasCalled(1) { args in
            let (token, name, observer) = args
            XCTAssertIdentical(token as AnyObject, tokenMock)
            XCTAssertEqual(name, NSNotification.Name.selectedKeyboardInputSourceChanged)
            XCTAssertNil(observer)
        }
    }
}

private enum TestData {
    static let inputEvent = InputEvent.keyDown(Keystroke(.Z))
    static let eventProxyStub = EventTapProxyStub()
    static let eventProxy = CGEventTapProxy(Unmanaged.passUnretained(eventProxyStub).toOpaque())
    
    static let engText = "Hello Мир"
    static let rusText = "Привет World"
}
