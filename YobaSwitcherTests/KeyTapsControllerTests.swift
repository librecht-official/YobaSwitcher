//
//  YobaSwitcherTests.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import Carbon
import CoreGraphics
import XCTest
@testable import YobaSwitcher

final class EventTapProxyStub {
    
}

final class KeyInputControllerTests: XCTestCase {
    var controller: KeyInputController!
    var keyboardMock: VirtualKeyboardMock!
    var systemWideMock: SystemWideAccessibilityMock!
    var mainQueueMock: DispatchQueueMock!
    var eventProxyMock: CGEventTapProxy!
    var eventProxyStub: EventTapProxyStub!
    
    override func setUpWithError() throws {
        keyboardMock = VirtualKeyboardMock(self)
        systemWideMock = SystemWideAccessibilityMock(self)
        mainQueueMock = DispatchQueueMock()
        eventProxyStub = EventTapProxyStub()
        eventProxyMock = CGEventTapProxy(Unmanaged.passUnretained(eventProxyStub).toOpaque())
        controller = KeyInputController(keyboard: keyboardMock, systemWide: systemWideMock, mainQueue: mainQueueMock)
    }
    
    // MARK: - GlobalInputMonitorHandler
    // MARK: handleKeyDown
    
    /// Ctrl+Opt+Z changes selected text case
    //    func testHandleKeyDown_CtrlOptZ_ToUppercase() {
    //        // given
    //        let event = CGEvent.keyDown(CGKeyCode(kVK_ANSI_Z))!
    //        event.flags = [.maskControl, .maskAlternate]
    //        // when
    //        let result = controller.handleKeyDown(event: event, proxy: eventProxyMock)
    //
    //        // TODO: Finish
    //    }
    
    //    func testHandleKeyDown_CtrlOptZ_ToLowercase() {
    //    func testHandleKeyDown_CtrlOptZ_NoSelectedText()
    
    // MARK: handleKeyUp
    
    /// Type "hello world" then press Option. It should delete 11 characters, switch input source and retype the same keys
    func testTypeAndPressOption() {
        // given
        let input = [
            kVK_ANSI_H, kVK_ANSI_E, kVK_ANSI_L, kVK_ANSI_L, kVK_ANSI_O,
            kVK_Space,
            kVK_ANSI_W, kVK_ANSI_O, kVK_ANSI_R, kVK_ANSI_L, kVK_ANSI_D,
        ]
        let kb = KeystrokesTracker()
        kb.setup(keyboardMock)
        
        // when
        for keyCode in input {
            pressCharacterKey(keyCode)
        }
        pressModifierKey(kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])
        
        // then
        XCTAssertEqual(kb.downKeystrokesBefore, Array(repeating: kVK_Delete, count: input.count))
        XCTAssertEqual(kb.downKeystrokesBefore, kb.upKeystrokesBefore)
        
        Assert.method(keyboardMock._switchInputSource, wasCalled: .once)
        
        XCTAssertEqual(kb.downKeystrokesAfter, input)
        XCTAssertEqual(kb.downKeystrokesAfter, kb.upKeystrokesAfter)
    }
    
    /// Type "hello ", then deletes 4 characters and types "y", so the result is "hey", then press Option. It should delete 3 characters, switch input source and retype "hey"
    func testTypeEraseAndPressOption() {
        // given
        let input = [
            kVK_ANSI_H, kVK_ANSI_E, kVK_ANSI_L, kVK_ANSI_L, kVK_ANSI_O,
            kVK_Space,
            kVK_Delete, kVK_Delete, kVK_ForwardDelete, kVK_ForwardDelete,
            kVK_ANSI_Y
        ]
        let kb = KeystrokesTracker()
        kb.setup(keyboardMock)
        
        // when
        for keyCode in input {
            pressCharacterKey(keyCode)
        }
        pressModifierKey(kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])
        
        // then
        XCTAssertEqual(kb.downKeystrokesBefore, Array(repeating: kVK_Delete, count: 3))
        XCTAssertEqual(kb.downKeystrokesBefore, kb.upKeystrokesBefore)
        
        Assert.method(keyboardMock._switchInputSource, wasCalled: .once)
        
        XCTAssertEqual(kb.downKeystrokesAfter, [kVK_ANSI_H, kVK_ANSI_E, kVK_ANSI_Y])
        XCTAssertEqual(kb.downKeystrokesAfter, kb.upKeystrokesAfter)
    }
    
    func testTypeNonCharacterKey() {
        // given
        let input = [kVK_ANSI_H, kVK_ANSI_E, kVK_F1]
        
        // when
        for keyCode in input {
            pressCharacterKey(keyCode)
        }
        pressModifierKey(kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])
        
        // then
        XCTAssertEqual(keyboardMock._postKeyDown.argumentsHistory.count, 0)
        XCTAssertEqual(keyboardMock._postKeyUp.argumentsHistory.count, 0)
        Assert.method(keyboardMock._switchInputSource, wasCalled: 0)
    }
    
    func testTypeShortCut() {
        // given
        let input = [kVK_ANSI_H, kVK_ANSI_E]
        
        // when
        for keyCode in input {
            pressCharacterKey(keyCode)
        }
        pressCharacterKey(kVK_ANSI_C, flags: [.maskCommand]) // Cmd+C
        pressModifierKey(kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])
        // кккккк
        // then
        XCTAssertEqual(keyboardMock._postKeyDown.argumentsHistory.count, 0)
        XCTAssertEqual(keyboardMock._postKeyUp.argumentsHistory.count, 0)
        Assert.method(keyboardMock._switchInputSource, wasCalled: 0)
    }
}

// MARK: Helpers
    
extension KeyInputControllerTests {
    func pressCharacterKey(_ keyCode: Int, flags: CGEventFlags = []) {
        let keyDown = CGEvent.keyDown(CGKeyCode(keyCode))!
        keyDown.flags = flags
        controller.handleKeyDown(event: keyDown, proxy: eventProxyMock)
        
        let keyUp = CGEvent.keyUp(CGKeyCode(keyCode))!
        controller.handleKeyUp(event: keyUp, proxy: eventProxyMock)
    }
    
    func pressModifierKey(_ keyCode: Int, flags: CGEventFlags) {
        let keyDown = CGEvent.keyDown(CGKeyCode(keyCode))!
        keyDown.flags = flags
        controller.handleFlagsChange(event: keyDown, proxy: eventProxyMock)
        
        let keyUp = CGEvent.keyUp(CGKeyCode(keyCode))!
        controller.handleFlagsChange(event: keyUp, proxy: eventProxyMock)
    }
}

final class KeystrokesTracker {
    var downKeystrokesBefore: [Int] = [] // Keystrokes (down) before switching input source
    var upKeystrokesBefore: [Int] = [] // Keystrokes (up) before switching input source
    var switchedInputSource = false
    var downKeystrokesAfter: [Int] = [] // Keystrokes (down) after switching input source
    var upKeystrokesAfter: [Int] = [] // Keystrokes (up) after switching input source
    
    func setup(_ keyboardMock: VirtualKeyboardMock) {
        keyboardMock._postKeyDown.body = { args in
            if self.switchedInputSource {
                self.downKeystrokesAfter.append(args.0)
            } else {
                self.downKeystrokesBefore.append(args.0)
            }
        }
        keyboardMock._postKeyUp.body = { args in
            if self.switchedInputSource {
                self.upKeystrokesAfter.append(args.0)
            } else {
                self.upKeystrokesBefore.append(args.0)
            }
        }
        keyboardMock._switchInputSource.body = { _ in self.switchedInputSource = true }
    }
}

//enum System {
//    static func pressKey(_ keyCode: Int) {
//        CGEvent.keyDown(CGKeyCode(keyCode))?.post(tap: .cghidEventTap)
//        CGEvent.keyUp(CGKeyCode(keyCode))?.post(tap: .cghidEventTap)
//    }
//
//    static func type(_ keyCodes: [Int]) {
//        for keyCode in keyCodes {
//            pressKey(keyCode)
//        }
//    }
//}



//final class KeyInputControllerTests: XCTestCase {
//    var controller: KeyInputController!
//    var inputMonitorMock: GlobalInputMonitorMock!
//
//    override func setUpWithError() throws {
//        inputMonitorMock = GlobalInputMonitorMock(self)
//        controller = KeyInputController(keysMonitor: inputMonitorMock)
//    }
//
//    // MARK: Start
//
//    func testStart() throws {
//        // when
//        controller.start()
//        // then
//        Assert.property(inputMonitorMock._delegate, wasSet: .once)
//        Assert.property(inputMonitorMock._delegate, identicalTo: controller)
//        Assert.method(inputMonitorMock._start, wasCalled: .once)
//    }
//
//    // MARK: - GlobalInputMonitorDelegate
//
//    // MARK: mouseDown
//
//
//}
