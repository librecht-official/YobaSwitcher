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

final class KeyInputControllerTests: XCTestCase {
    var controller: KeyInputController!
    var keyboardMock: VirtualKeyboardMock!
    var systemWideMock: SystemWideAccessibilityMock!
    var mainQueueMock: DispatchQueueMock!
    var eventProxyMock: CGEventTapProxy!
    var eventProxyStub: EventTapProxyStub!
    var ksRecorder: KeystrokesRecorder!
    
    override func setUpWithError() throws {
        keyboardMock = VirtualKeyboardMock(self)
        ksRecorder = KeystrokesRecorder()
        ksRecorder.setup(keyboardMock)
        systemWideMock = SystemWideAccessibilityMock(self)
        mainQueueMock = DispatchQueueMock()
        eventProxyStub = EventTapProxyStub()
        eventProxyMock = CGEventTapProxy(Unmanaged.passUnretained(eventProxyStub).toOpaque())
        controller = KeyInputController(keyboard: keyboardMock, systemWide: systemWideMock, mainQueue: mainQueueMock)
    }
    
    // MARK: - Type and press Option
    
    /// Type "§1234567890-=qwertyuiop[]asdfghjkl;'\`zxcvbnm,./", space, tab and return then press Right Option. It should delete all characters, switch input source and retype the same keys
    func testTypeCharacterKeys() {
        // given
        let input = Keystrokes.allCharacterProducing + Keystrokes.rightOption
        
        // when
        for event in input {
            performKeystrokeEvent(event)
        }
        
        // then
        let backspaces = Keystrokes.backspaces(count: (Keystrokes.allCharacterProducing.count / 2))
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, backspaces)
        Assert.method(keyboardMock._switchInputSource, wasCalled: .once)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.allCharacterProducing)
    }
    
    /// Type "hello world", then delete 2 characters and types "d", so the result is "hello word", then press Option. It should delete 10 characters, switch input source and retype "hello word"
    func testTypeEraseAndPressOption() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.option
        
        // when
        for event in input {
            performKeystrokeEvent(event)
        }
        
        // then
        let backspaces = Keystrokes.backspaces(count: 10)
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, backspaces)
        Assert.method(keyboardMock._switchInputSource, wasCalled: .once)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.hello_word)
    }
    
    /// Type "hello world", then press Left Arrow, then press Option. It should do nothing because of Left Arrow
    func testTypeNonCharacterKey_LeftArrow() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.leftArrow + Keystrokes.option
        
        // when
        for event in input {
            performKeystrokeEvent(event)
        }
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        Assert.method(keyboardMock._switchInputSource, wasCalled: 0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", then press Cmd+C, then press Option. It should do nothing because of short cut
    func testTypeShortCut_CmdC_1() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.cmd_c_1 + Keystrokes.option
        
        // when
        for event in input {
            performKeystrokeEvent(event)
        }
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        Assert.method(keyboardMock._switchInputSource, wasCalled: 0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", then press Cmd+C, then press Option. It should do nothing because of short cut. Cmd+C is typed differently
    func testTypeShortCut_CmdC_2() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.cmd_c_2 + Keystrokes.option
        
        // when
        for event in input {
            performKeystrokeEvent(event)
        }
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        Assert.method(keyboardMock._switchInputSource, wasCalled: 0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
}

// MARK: Helpers

final class EventTapProxyStub {}

extension KeyInputControllerTests {
    func performKeystrokeEvent(_ event: KeystrokeEvent) {
        let cgEvent = CGEvent.fromKeystrokeEvent(event)!
        switch event {
        case .keyDown:
            controller.handleKeyDown(event: cgEvent, proxy: eventProxyMock)
        case .keyUp:
            controller.handleKeyUp(event: cgEvent, proxy: eventProxyMock)
        case .flagsChanged:
            controller.handleFlagsChange(event: cgEvent, proxy: eventProxyMock)
        case .mouseDown:
            controller.handleMouseDown(event: cgEvent, proxy: eventProxyMock)
        }
    }
}

final class KeystrokesRecorder {
    /// Keystrockes before switching input source (switchedInputSource == false)
    var keystrokesBeforeSwitching: [KeystrokeEvent] = []
    /// Keystrockes after switching input source (switchedInputSource == true)
    var keystrokesAfterSwitching: [KeystrokeEvent] = []
    /// Indicates that switchInputSource() was called on virtual keyboard
    var switchedInputSource = false
    
    func setup(_ keyboardMock: VirtualKeyboardMock) {
        keyboardMock._postKeystrokeEvent.body = { args in
            if self.switchedInputSource {
                self.keystrokesAfterSwitching.append(args.0)
            } else {
                self.keystrokesBeforeSwitching.append(args.0)
            }
        }
        keyboardMock._switchInputSource.body = { _ in self.switchedInputSource = true }
    }
}

enum Keystrokes {
    static let rightOption: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_RightOption, flags: [.maskAlternate, .maskNonCoalesced])), // opt down
        .flagsChanged(Keystroke(keyCode: kVK_RightOption, flags: .maskNonCoalesced)), // opt up
    ]
    
    static let option: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])), // opt down
        .flagsChanged(Keystroke(keyCode: kVK_Option, flags: .maskNonCoalesced)), // opt up
    ]
    
    static let leftArrow: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_LeftArrow)),
        .keyUp(Keystroke(keyCode: kVK_LeftArrow)),
    ]
    
    static let cmd_c_1: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: [.maskCommand, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: .maskNonCoalesced)),
    ]
    
    static let cmd_c_2: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: [.maskCommand, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_C, flags: .maskNonCoalesced)),
    ]
    
    static func backspaces(count: Int) -> [KeystrokeEvent] {
        [
            .keyDown(Keystroke(keyCode: kVK_Delete)),
            .keyUp(Keystroke(keyCode: kVK_Delete)),
        ] * count
    }
    
    static let hello_world: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_ANSI_H, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_H, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_E, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_E, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_Space, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_Space, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_W, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_W, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_R, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_R, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_Delete, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_Delete, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ForwardDelete, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ForwardDelete, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
    ]
    
    static let hello_word: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_ANSI_H, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_H, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_E, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_E, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_Space, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_Space, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_W, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_W, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_R, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_R, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_D, flags: .maskNonCoalesced)),
    ]
    
    static let allCharacterProducing: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: 10, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 10, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 18, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 18, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 19, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 19, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 20, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 20, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 21, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 21, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 23, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 23, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 22, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 22, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 26, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 26, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 28, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 28, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 25, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 25, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 29, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 29, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 27, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 27, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 24, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 24, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 12, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 12, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 13, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 13, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 14, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 14, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 15, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 15, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 17, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 17, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 16, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 16, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 32, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 32, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 34, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 34, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 31, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 31, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 35, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 35, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 33, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 33, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 30, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 30, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 0, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 0, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 1, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 1, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 2, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 2, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 3, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 3, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 5, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 5, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 4, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 4, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 38, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 38, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 40, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 40, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 37, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 37, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 41, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 41, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 39, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 39, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 42, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 42, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 50, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 50, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 6, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 6, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 7, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 7, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 8, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 8, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 9, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 9, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 11, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 11, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 45, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 45, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 46, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 46, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 43, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 43, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 47, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 47, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 44, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 44, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 49, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 49, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 48, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 48, flags: .maskNonCoalesced)),
        .keyDown(Keystroke(keyCode: 36, flags: .maskNonCoalesced)),
        .keyUp(Keystroke(keyCode: 36, flags: .maskNonCoalesced)),
    ]
}

func * <C>(lhs: C, rhs: Int) -> [C.Element] where C: Sequence {
    var result: [C.Element] = []
    for _ in 0..<rhs {
        result.append(contentsOf: lhs)
    }
    return result
}
