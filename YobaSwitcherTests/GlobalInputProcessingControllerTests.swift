//
//  GlobalInputProcessingControllerTests.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import Carbon
import CoreGraphics
import XCTest
@testable import YobaSwitcher

final class GlobalInputProcessingControllerTests: XCTestCase {
    var controller: GlobalInputProcessingController!
    var selectedTextManagerMock: SelectedTextManagerMock!
    var keyboardMock: VirtualKeyboardMock!
    var systemWideMock: SystemWideAccessibilityMock!
    var focusedUIElementMock: FocusedUIElementMock!
    var eventProxyMock: CGEventTapProxy!
    var eventProxyStub: EventTapProxyStub!
    var ksRecorder: KeystrokesRecorder!
    
    override func setUpWithError() throws {
        keyboardMock = VirtualKeyboardMock(self)
        ksRecorder = KeystrokesRecorder()
        ksRecorder.setup(keyboardMock)
        systemWideMock = SystemWideAccessibilityMock(self)
        focusedUIElementMock = FocusedUIElementMock(self)
        eventProxyStub = EventTapProxyStub()
        eventProxyMock = CGEventTapProxy(Unmanaged.passUnretained(eventProxyStub).toOpaque())
        selectedTextManagerMock = SelectedTextManagerMock(self)
        controller = GlobalInputProcessingController(selectedTextManager: selectedTextManagerMock, keyboard: keyboardMock, systemWide: systemWideMock)
        
        systemWideMock._focusedElement.returnValue = focusedUIElementMock
        selectedTextManagerMock._replaceSelectedTextWithAlternativeKeyboardLanguage.returnValue = false
    }
    
    // MARK: - Type and press Option
    
    /// Type "§1234567890-=qwertyuiop[]asdfghjkl;'\`zxcvbnm,./", space, tab and return then press Right Option. It should delete all characters, switch input source and retype the same keys
    func testTypeCharacterKeys() {
        // given
        let input = Keystrokes.allCharacterProducing + Keystrokes.rightOption
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        let backspaces = Keystrokes.backspaces(count: (Keystrokes.allCharacterProducing.count / 2))
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, backspaces)
        keyboardMock._switchInputSourceCompletion.wasCalled(1)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.allCharacterProducing)
    }
    
    /// Type "hello world", then delete 2 characters and types "d", so the result is "hello word", then press Option. It should delete 10 characters, switch input source and retype "hello word"
    func testTypeEraseAndPressOption() {
        // given
        let input = Keystrokes.hello_world + [
            .keyDown(Keystroke(keyCode: kVK_Delete)),
            .keyUp(Keystroke(keyCode: kVK_Delete)),
            .keyDown(Keystroke(keyCode: kVK_ForwardDelete)),
            .keyUp(Keystroke(keyCode: kVK_ForwardDelete)),
            .keyDown(Keystroke(keyCode: kVK_ANSI_D)),
            .keyUp(Keystroke(keyCode: kVK_ANSI_D)),
        ] + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        let backspaces = Keystrokes.backspaces(count: 10)
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, backspaces)
        keyboardMock._switchInputSourceCompletion.wasCalled(1)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.hello_word)
    }
    
    /// Type "hello world", then press Left Arrow, then press Option. It should do nothing because of Left Arrow
    func testTypeNonCharacterKey_LeftArrow() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.leftArrow + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", then press Cmd+C, then press Option. It should do nothing because of short cut
    func testTypeShortCut_CmdC_1() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.cmd_c_1 + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", then press Cmd+C, then press Option. It should do nothing because of short cut. Cmd+C is typed differently
    func testTypeShortCut_CmdC_2() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.cmd_c_2 + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", press Q while holding Option, so the character is œ. Release keys and press Option normally. It should do nothing
    func testTypeAlternateCharacter_Q_1() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.altQ_1 + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", press Q while holding Option, so the character is œ. Release keys and press Option normally. It should do nothing
    func testTypeAlternateCharacter_Q_2() {
        // given
        let input = Keystrokes.hello_world + Keystrokes.altQ_2 + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "hello world", click mouse and press Option. It should do nothing
    func testTypeAndClickMouse() {
        // given
        let input = Keystrokes.hello_world + [.mouseDown] + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
    
    /// Type "Hello World!" and press Option. It should delete all characters, switch input source and retype them preserving uppercased characters with Shift key
    func testTypeWithShift() {
        // given
        let input = Keystrokes.Hello_World1 + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        let backspaces = Keystrokes.backspaces(count: 12)
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, backspaces)
        keyboardMock._switchInputSourceCompletion.wasCalled(1)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.Hello_World2)
    }
    
    /// Type "hello", press Option, type " world" and press Option again
    func testType_PressOption_Type_PressOption() {
        // given
        let input = Keystrokes.hello + Keystrokes.option + Keystrokes.space + Keystrokes.world + Keystrokes.option
        
        // when
        input.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, Keystrokes.backspaces(count: 5) + Keystrokes.hello_world)
        keyboardMock._switchInputSourceCompletion.wasCalled(2)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, Keystrokes.hello + Keystrokes.backspaces(count: 11))
    }
    
    // MARK: Switching selected text language
    
    /// When there is selected text somewhere replaceSelectedTextWithAlternativeKeyboardLanguage() returns true. In this case when Option is pressed controller should replace selected text and not produce keystrokes
    func testSwitchingSelectedTextLanguage() {
        // given
        selectedTextManagerMock._replaceSelectedTextWithAlternativeKeyboardLanguage.returnValue = true
        let keystrokes = Keystrokes.hello + Keystrokes.option
        
        // when
        keystrokes.forEach(performKeystrokeEvent)
        
        // then
        XCTAssertEqual(ksRecorder.keystrokesBeforeSwitching, [])
        keyboardMock._switchInputSourceCompletion.wasCalled(0)
        XCTAssertEqual(ksRecorder.keystrokesAfterSwitching, [])
    }
}

// MARK: - Helpers

final class EventTapProxyStub {}

extension GlobalInputProcessingControllerTests {
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
        keyboardMock._switchInputSourceCompletion.body = { completion in
            self.switchedInputSource.toggle()
            completion()
        }
    }
}

enum Keystrokes {
    static let rightOption: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_RightOption, flags: [.maskAlternate, .maskNonCoalesced])), // opt down
        .flagsChanged(Keystroke(keyCode: kVK_RightOption)), // opt up
    ]
    
    static let option: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])), // opt down
        .flagsChanged(Keystroke(keyCode: kVK_Option)), // opt up
    ]
    
    static let leftArrow: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_LeftArrow)),
        .keyUp(Keystroke(keyCode: kVK_LeftArrow)),
    ]
    
    static let cmd_c_1: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: [.maskCommand, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Command)),
    ]
    
    static let cmd_c_2: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Command, flags: [.maskCommand, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_C, flags: [.maskCommand, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Command)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_C)),
    ]
    
    static let altQ_1: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_Q, flags: [.maskAlternate, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: kVK_ANSI_Q, flags: [.maskAlternate, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Option)),
    ]
    
    static let altQ_2: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: kVK_Option, flags: [.maskAlternate, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: kVK_ANSI_Q, flags: [.maskAlternate, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: kVK_Option)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_Q)),
    ]
    
    static func backspaces(count: Int) -> [KeystrokeEvent] {
        [
            .keyDown(Keystroke(keyCode: kVK_Delete)),
            .keyUp(Keystroke(keyCode: kVK_Delete)),
        ] * count
    }
    
    static let hello: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_ANSI_H)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_H)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_E)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_E)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O)),
    ]
    
    static let space: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_Space)),
        .keyUp(Keystroke(keyCode: kVK_Space)),
    ]
    
    static let world: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: kVK_ANSI_W)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_W)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_R)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_R)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_L)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_L)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_D)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_D)),
    ]
    
    static let hello_world = hello + space + world
    
    static let hello_word: [KeystrokeEvent] = hello + space + [
        .keyDown(Keystroke(keyCode: kVK_ANSI_W)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_W)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_O)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_O)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_R)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_R)),
        .keyDown(Keystroke(keyCode: kVK_ANSI_D)),
        .keyUp(Keystroke(keyCode: kVK_ANSI_D)),
    ]
    
    static let Hello_World1: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced]), keyDown: true),
        .keyDown(Keystroke(keyCode: 4, flags: [.maskShift, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: 4, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56)),
        .keyDown(Keystroke(keyCode: 14)),
        .keyUp(Keystroke(keyCode: 14)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 31)),
        .keyUp(Keystroke(keyCode: 31)),
        .keyDown(Keystroke(keyCode: 49)),
        .keyUp(Keystroke(keyCode: 49)),
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: 13, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56)),
        .keyUp(Keystroke(keyCode: 13)),
        .keyDown(Keystroke(keyCode: 31)),
        .keyUp(Keystroke(keyCode: 31)),
        .keyDown(Keystroke(keyCode: 15)),
        .keyUp(Keystroke(keyCode: 15)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 2)),
        .keyUp(Keystroke(keyCode: 2)),
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced])),
        .keyDown(Keystroke(keyCode: 18, flags: [.maskShift, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: 18, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56)),
    ]
    
    static let Hello_World2: [KeystrokeEvent] = [
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced]), keyDown: true),
        .keyDown(Keystroke(keyCode: 4, flags: [.maskShift, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: 4, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56), keyDown: false),
        .keyDown(Keystroke(keyCode: 14)),
        .keyUp(Keystroke(keyCode: 14)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 31)),
        .keyUp(Keystroke(keyCode: 31)),
        .keyDown(Keystroke(keyCode: 49)),
        .keyUp(Keystroke(keyCode: 49)),
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced]), keyDown: true),
        .keyDown(Keystroke(keyCode: 13, flags: [.maskShift, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: 13, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56), keyDown: false),
        .keyDown(Keystroke(keyCode: 31)),
        .keyUp(Keystroke(keyCode: 31)),
        .keyDown(Keystroke(keyCode: 15)),
        .keyUp(Keystroke(keyCode: 15)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 2)),
        .keyUp(Keystroke(keyCode: 2)),
        .flagsChanged(Keystroke(keyCode: 56, flags: [.maskShift, .maskNonCoalesced]), keyDown: true),
        .keyDown(Keystroke(keyCode: 18, flags: [.maskShift, .maskNonCoalesced])),
        .keyUp(Keystroke(keyCode: 18, flags: [.maskShift, .maskNonCoalesced])),
        .flagsChanged(Keystroke(keyCode: 56), keyDown: false)
    ]
    
    static let allCharacterProducing: [KeystrokeEvent] = [
        .keyDown(Keystroke(keyCode: 10)),
        .keyUp(Keystroke(keyCode: 10)),
        .keyDown(Keystroke(keyCode: 18)),
        .keyUp(Keystroke(keyCode: 18)),
        .keyDown(Keystroke(keyCode: 19)),
        .keyUp(Keystroke(keyCode: 19)),
        .keyDown(Keystroke(keyCode: 20)),
        .keyUp(Keystroke(keyCode: 20)),
        .keyDown(Keystroke(keyCode: 21)),
        .keyUp(Keystroke(keyCode: 21)),
        .keyDown(Keystroke(keyCode: 23)),
        .keyUp(Keystroke(keyCode: 23)),
        .keyDown(Keystroke(keyCode: 22)),
        .keyUp(Keystroke(keyCode: 22)),
        .keyDown(Keystroke(keyCode: 26)),
        .keyUp(Keystroke(keyCode: 26)),
        .keyDown(Keystroke(keyCode: 28)),
        .keyUp(Keystroke(keyCode: 28)),
        .keyDown(Keystroke(keyCode: 25)),
        .keyUp(Keystroke(keyCode: 25)),
        .keyDown(Keystroke(keyCode: 29)),
        .keyUp(Keystroke(keyCode: 29)),
        .keyDown(Keystroke(keyCode: 27)),
        .keyUp(Keystroke(keyCode: 27)),
        .keyDown(Keystroke(keyCode: 24)),
        .keyUp(Keystroke(keyCode: 24)),
        .keyDown(Keystroke(keyCode: 12)),
        .keyUp(Keystroke(keyCode: 12)),
        .keyDown(Keystroke(keyCode: 13)),
        .keyUp(Keystroke(keyCode: 13)),
        .keyDown(Keystroke(keyCode: 14)),
        .keyUp(Keystroke(keyCode: 14)),
        .keyDown(Keystroke(keyCode: 15)),
        .keyUp(Keystroke(keyCode: 15)),
        .keyDown(Keystroke(keyCode: 17)),
        .keyUp(Keystroke(keyCode: 17)),
        .keyDown(Keystroke(keyCode: 16)),
        .keyUp(Keystroke(keyCode: 16)),
        .keyDown(Keystroke(keyCode: 32)),
        .keyUp(Keystroke(keyCode: 32)),
        .keyDown(Keystroke(keyCode: 34)),
        .keyUp(Keystroke(keyCode: 34)),
        .keyDown(Keystroke(keyCode: 31)),
        .keyUp(Keystroke(keyCode: 31)),
        .keyDown(Keystroke(keyCode: 35)),
        .keyUp(Keystroke(keyCode: 35)),
        .keyDown(Keystroke(keyCode: 33)),
        .keyUp(Keystroke(keyCode: 33)),
        .keyDown(Keystroke(keyCode: 30)),
        .keyUp(Keystroke(keyCode: 30)),
        .keyDown(Keystroke(keyCode: 0)),
        .keyUp(Keystroke(keyCode: 0)),
        .keyDown(Keystroke(keyCode: 1)),
        .keyUp(Keystroke(keyCode: 1)),
        .keyDown(Keystroke(keyCode: 2)),
        .keyUp(Keystroke(keyCode: 2)),
        .keyDown(Keystroke(keyCode: 3)),
        .keyUp(Keystroke(keyCode: 3)),
        .keyDown(Keystroke(keyCode: 5)),
        .keyUp(Keystroke(keyCode: 5)),
        .keyDown(Keystroke(keyCode: 4)),
        .keyUp(Keystroke(keyCode: 4)),
        .keyDown(Keystroke(keyCode: 38)),
        .keyUp(Keystroke(keyCode: 38)),
        .keyDown(Keystroke(keyCode: 40)),
        .keyUp(Keystroke(keyCode: 40)),
        .keyDown(Keystroke(keyCode: 37)),
        .keyUp(Keystroke(keyCode: 37)),
        .keyDown(Keystroke(keyCode: 41)),
        .keyUp(Keystroke(keyCode: 41)),
        .keyDown(Keystroke(keyCode: 39)),
        .keyUp(Keystroke(keyCode: 39)),
        .keyDown(Keystroke(keyCode: 42)),
        .keyUp(Keystroke(keyCode: 42)),
        .keyDown(Keystroke(keyCode: 50)),
        .keyUp(Keystroke(keyCode: 50)),
        .keyDown(Keystroke(keyCode: 6)),
        .keyUp(Keystroke(keyCode: 6)),
        .keyDown(Keystroke(keyCode: 7)),
        .keyUp(Keystroke(keyCode: 7)),
        .keyDown(Keystroke(keyCode: 8)),
        .keyUp(Keystroke(keyCode: 8)),
        .keyDown(Keystroke(keyCode: 9)),
        .keyUp(Keystroke(keyCode: 9)),
        .keyDown(Keystroke(keyCode: 11)),
        .keyUp(Keystroke(keyCode: 11)),
        .keyDown(Keystroke(keyCode: 45)),
        .keyUp(Keystroke(keyCode: 45)),
        .keyDown(Keystroke(keyCode: 46)),
        .keyUp(Keystroke(keyCode: 46)),
        .keyDown(Keystroke(keyCode: 43)),
        .keyUp(Keystroke(keyCode: 43)),
        .keyDown(Keystroke(keyCode: 47)),
        .keyUp(Keystroke(keyCode: 47)),
        .keyDown(Keystroke(keyCode: 44)),
        .keyUp(Keystroke(keyCode: 44)),
        .keyDown(Keystroke(keyCode: 49)),
        .keyUp(Keystroke(keyCode: 49)),
        .keyDown(Keystroke(keyCode: 48)),
        .keyUp(Keystroke(keyCode: 48)),
        .keyDown(Keystroke(keyCode: 36)),
        .keyUp(Keystroke(keyCode: 36)),
    ]
}

func * <C>(lhs: C, rhs: Int) -> [C.Element] where C: Sequence {
    var result: [C.Element] = []
    for _ in 0..<rhs {
        result.append(contentsOf: lhs)
    }
    return result
}
