//
//  Created by Vladislav Librecht on 12.05.2026
//

import Testing
import CoreGraphics
import Carbon
@testable import YobaSwitcher

@MainActor
struct GlobalInputProcessingTests {
    let events = SystemEventsRecorder()
    let pasteboard = PasteboardEmulator()
    
    let processor: GlobalInputProcessor<CGEvent>
    
    init() {
        StaticDependency.systemEvents = events
        StaticDependency.pasteboard = pasteboard
        
        let tisAPIEmulator = TISAPIEmulator()
        
        let tisManager = DefaultTextInputSourceManager(
            distributedNotificationCenter: tisAPIEmulator,
            tis: tisAPIEmulator
        )
        
        self.processor = GlobalInputProcessor(
            selectedTextManager: SystemWideSelectedTextManager(tisManager: tisManager),
            inputSourceManager: tisManager
        )
    }
    
    // MARK: Typing traslation
    
    /// Type 'hello' then press <option>.
    ///
    /// It should delete exactly 5 characters, switch input source and retype the same keys
    @Test
    func hello() {
        // given
        let input = Input.hello + Input.option
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 5) + Input.hello.map(InputEvent.init)
        #expect(events.recordedEvents == expected)
    }
    
    /// Type 'Hello World' then press <option>.
    ///
    /// It should delete exactly 11 characters, switch input source and retype the same keys
    @Test
    func helloWorld() {
        // given
        let input = Input.Hello_World + Input.option
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 11) + Output.Hello_World
        #expect(events.recordedEvents == expected)
    }
    
    /// Type all english letter keys then press <right option>.
    ///
    /// It should delete all characters, switch input source and retype the same keys
    @Test
    func letters() {
        // given
        let input = Input.letters + Input.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 26) + Input.letters.map(InputEvent.init)
        #expect(events.recordedEvents == expected)
    }
    
    /// Type all english letter keys with <shift>, then press <right option>.
    ///
    /// It should delete all characters, switch input source and retype the same keys
    @Test
    func lettersWithShift() {
        // given
        let input = Input.lettersWithShift + Input.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 26) + Input.lettersWithShift.map(InputEvent.init)
        #expect(events.recordedEvents == expected)
    }
    
    /// Type all numeric keys, then press <right option>.
    ///
    /// It should delete all characters, switch input source and retype the same keys
    @Test
    func numerics() {
        // given
        let input = Input.numerics + Input.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 10) + Input.numerics.map(InputEvent.init)
        #expect(events.recordedEvents == expected)
    }
    
    /// Type all special character keys, then press <right option>.
    ///
    /// It should delete all characters, switch input source and retype the same keys.
    @Test
    func specialCharacters() {
        // given
        let input = Input.specialCharacters + Input.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 34) + Input.specialCharacters.map(InputEvent.init)
        #expect(events.recordedEvents == expected)
    }
    
    /// Type 'Hello World', delete 5 characters, then press <option>.
    ///
    /// It should delete 6 characters ('Hello '), switch input source and retype 'Hello '.
    @Test
    func backspaces() {
        // given
        let input = Input.Hello_World + Input.backspaces(count: 5) + Input.option
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 6) + Output.Hello + Output.space
        #expect(events.recordedEvents == expected)
    }
    
    /// Type 'Hello World', delete 5 characters, type 'Alice' then press <option>.
    ///
    /// It should delete all characters, switch input source and retype 'Hello Alice'.
    @Test
    func backspaces2() {
        // given
        let input = Input.Hello_World + Input.backspaces(count: 5) + Input.Alice + Input.option
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 11) + Output.Hello_Alice
        #expect(events.recordedEvents == expected)
    }
    
    /// Type text with capslock on and hit <option>
    ///
    /// It should delete text and retype it preseving capslock
    @Test
    func capslock() {
        // given
        let input = Input.capslockAndOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 3) + Output.capslock
        #expect(events.recordedEvents == expected)
    }
    
    /// Type text with partially capslock on and off and hit <option>
    ///
    /// It should delete text and retype it preseving capslock
    @Test
    func capslockMixed() {
        // given
        let input = Input.capslockMixedAndOption
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.backspaces(count: 4) + Output.capslockMixed
        #expect(events.recordedEvents == expected)
    }
    
    /// Type 'qwerty' then perform special keystroke (short cut, arrows, escape or mouse down), then hit <option>.
    ///
    /// It should not retype 'qwerty'. <cmd + C> is triggered in attempt to get selected text.
    @Test("Drops character buffer when meets special keys", arguments: [
        Input.fnA, Input.controlA, Input.optionA, Input.commandA,
        Input.upArrow, Input.downArrow, Input.leftArrow, Input.rightArrow,
        Input.escape,
        Input.mouseDown
    ])
    func bufferDrop(on specialKeys: [CGEvent]) {
        // given
        let input = Input.qwerty + specialKeys + Input.option
        // when
        input.forEach(processInputEvent)
        // then
        let expected = Output.commandC
        #expect(events.recordedEvents == expected)
    }
    
    /// Type 'hello', press <option>, type 'Alice' and press <option> again.
    ///
    /// Firstly it should delete 5 characters and retype it. Then it should delete 10 characters and retype 'helloAlice'.
    @Test
    func doubleSwitch() {
        // given
        let input = Input.hello + Input.option + Input.Alice + Input.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let hello = Input.hello.map(InputEvent.init)
        let expected = Output.backspaces(count: 5) + hello + Output.backspaces(count: 10) + hello + Output.Alice
        #expect(events.recordedEvents == expected)
    }
    
    // MARK: - Selected Text switching
    
    /// Switch selected text. Base case
    @Test("Should switch selected text keyboard layout (launguage)", arguments: [
        (TestData.engCharacters, TestData.rusCharacters),
        (TestData.rusCharacters, TestData.engCharacters),
        (TestData.engBeginsWithEmoji, TestData.rusBeginsWithEmoji),
        (TestData.rusBeginsWithEmoji, TestData.engBeginsWithEmoji),
        (TestData.engBeginsWithSpace, TestData.rusBeginsWithSpace),
        (TestData.rusBeginsWithSpace, TestData.engBeginsWithSpace),
        (TestData.engBeginsWithNumeric, TestData.rusBeginsWithNumeric),
        (TestData.rusBeginsWithNumeric, TestData.engBeginsWithNumeric),
        (TestData.noLetters, TestData.noLetters),
    ])
    func switchSelectedText(input: String, expected: String) {
        // given
        events.pasteboard = pasteboard
        pasteboard._selectedText = input
        // when
        Input.option.forEach(processInputEvent)
        // then
        // it should perform copy-paste
        #expect(events.recordedEvents == Output.copyPaste)
        // selected text should be switched to alternative
        #expect(pasteboard._selectedText == expected)
        // pasteboard should have the same content as before switching
        #expect(pasteboard.pasteboardItems == pasteboard._initialItems)
    }
    
    @Test("Should switch selected text case", arguments: [
        (TestData.lowercased, TestData.uppercased),
        (TestData.uppercased, TestData.lowercased),
        (TestData.mixcased, TestData.uppercased),
        (TestData.mixcasedCapitalized, TestData.uppercased),
    ])
    func switchSelectedTextCase(input: String, expected: String) {
        // given
        events.pasteboard = pasteboard
        pasteboard._selectedText = input
        // when
        Input.crtlOptZ.forEach(processInputEvent)
        // then
        // it should perform copy-paste
        #expect(events.recordedEvents == Output.copyPaste)
        // selected text should be case-switched
        #expect(pasteboard._selectedText == expected)
        // pasteboard should have the same content as before switching
        #expect(pasteboard.pasteboardItems == pasteboard._initialItems)
    }
    
    @Test
    func switchSelectedTextCase_NoText() {
        // given
        events.pasteboard = pasteboard
        pasteboard._selectedText = nil
        // when
        Input.crtlOptZ.forEach(processInputEvent)
        // then
        // it should perform only copy
        #expect(events.recordedEvents == Output.commandC)
        // selected text should be case-switched
        #expect(pasteboard._selectedText == nil)
        // pasteboard should have the same content as before switching
        #expect(pasteboard.pasteboardItems == pasteboard._initialItems)
    }
    
    // MARK: - Helpers
    
    func processInputEvent(_ event: CGEvent) {
        let proxyStub = EventTapProxyStub()
        let tapProxy = CGEventTapProxy(Unmanaged.passUnretained(proxyStub).toOpaque())
        _ = processor.handleEvent(event: event, proxy: tapProxy)
    }
}

private enum Input {
    static let option = [
        CGEvent.flagsChanged(kVK_Option, .maskAlternate),
        CGEvent.flagsChanged(kVK_Option),
    ]
    
    static let rightOption = [
        CGEvent.flagsChanged(kVK_RightOption, .maskAlternate),
        CGEvent.flagsChanged(kVK_RightOption),
    ]
    
    static func backspaces(count: Int) -> [CGEvent] {
        [
            CGEvent.key(.down,   kVK_Delete),
            CGEvent.key(.up,     kVK_Delete),
        ] * count
    }
    
    static let hello = [
        CGEvent.key(.down,   kVK_ANSI_H),
        CGEvent.key(.up,     kVK_ANSI_H),
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_E),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_O),
        CGEvent.key(.up,     kVK_ANSI_O),
    ]
    
    static let Hello_World = [
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_H, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_H, .maskShift),
        CGEvent.flagsChanged(kVK_Shift),
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_E),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_O),
        CGEvent.key(.up,     kVK_ANSI_O),
        CGEvent.key(.down,   kVK_Space),
        CGEvent.key(.up,     kVK_Space),
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_W, .maskShift),
        CGEvent.flagsChanged(kVK_Shift), // 'Flag change' before W↑ - this is valid input,
        CGEvent.key(.up,     kVK_ANSI_W),// although retyping algorithm releases Shift after letter-up
        CGEvent.key(.down,   kVK_ANSI_O),
        CGEvent.key(.up,     kVK_ANSI_O),
        CGEvent.key(.down,   kVK_ANSI_R),
        CGEvent.key(.up,     kVK_ANSI_R),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_D),
        CGEvent.key(.up,     kVK_ANSI_D),
    ]
    
    static let letters = [
        CGEvent.key(.down,   kVK_ANSI_Q),
        CGEvent.key(.up,     kVK_ANSI_Q),
        CGEvent.key(.down,   kVK_ANSI_W),
        CGEvent.key(.up,     kVK_ANSI_W),
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_E),
        CGEvent.key(.down,   kVK_ANSI_R),
        CGEvent.key(.up,     kVK_ANSI_R),
        CGEvent.key(.down,   kVK_ANSI_T),
        CGEvent.key(.up,     kVK_ANSI_T),
        CGEvent.key(.down,   kVK_ANSI_Y),
        CGEvent.key(.up,     kVK_ANSI_Y),
        CGEvent.key(.down,   kVK_ANSI_U),
        CGEvent.key(.up,     kVK_ANSI_U),
        CGEvent.key(.down,   kVK_ANSI_I),
        CGEvent.key(.up,     kVK_ANSI_I),
        CGEvent.key(.down,   kVK_ANSI_O),
        CGEvent.key(.up,     kVK_ANSI_O),
        CGEvent.key(.down,   kVK_ANSI_P),
        CGEvent.key(.up,     kVK_ANSI_P),
        CGEvent.key(.down,   kVK_ANSI_A),
        CGEvent.key(.up,     kVK_ANSI_A),
        CGEvent.key(.down,   kVK_ANSI_S),
        CGEvent.key(.up,     kVK_ANSI_S),
        CGEvent.key(.down,   kVK_ANSI_D),
        CGEvent.key(.up,     kVK_ANSI_D),
        CGEvent.key(.down,   kVK_ANSI_F),
        CGEvent.key(.up,     kVK_ANSI_F),
        CGEvent.key(.down,   kVK_ANSI_G),
        CGEvent.key(.up,     kVK_ANSI_G),
        CGEvent.key(.down,   kVK_ANSI_H),
        CGEvent.key(.up,     kVK_ANSI_H),
        CGEvent.key(.down,   kVK_ANSI_J),
        CGEvent.key(.up,     kVK_ANSI_J),
        CGEvent.key(.down,   kVK_ANSI_K),
        CGEvent.key(.up,     kVK_ANSI_K),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_Z),
        CGEvent.key(.up,     kVK_ANSI_Z),
        CGEvent.key(.down,   kVK_ANSI_X),
        CGEvent.key(.up,     kVK_ANSI_X),
        CGEvent.key(.down,   kVK_ANSI_C),
        CGEvent.key(.up,     kVK_ANSI_C),
        CGEvent.key(.down,   kVK_ANSI_V),
        CGEvent.key(.up,     kVK_ANSI_V),
        CGEvent.key(.down,   kVK_ANSI_B),
        CGEvent.key(.up,     kVK_ANSI_B),
        CGEvent.key(.down,   kVK_ANSI_N),
        CGEvent.key(.up,     kVK_ANSI_N),
        CGEvent.key(.down,   kVK_ANSI_M),
        CGEvent.key(.up,     kVK_ANSI_M),
    ]
    
    static let lettersWithShift = [
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Q, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Q, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_W, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_W, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_E, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_E, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_R, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_R, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_T, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_T, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Y, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Y, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_U, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_U, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_I, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_I, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_O, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_O, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_P, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_P, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_A, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_A, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_S, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_S, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_D, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_D, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_F, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_F, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_G, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_G, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_H, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_H, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_J, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_J, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_K, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_K, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_L, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_L, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Z, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Z, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_X, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_X, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_C, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_C, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_V, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_V, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_B, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_B, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_N, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_N, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_M, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_M, .maskShift),
        CGEvent.flagsChanged(kVK_Shift),
    ]
    
    static let numerics = [
        CGEvent.key(.down,   kVK_ANSI_1),
        CGEvent.key(.up,     kVK_ANSI_1),
        CGEvent.key(.down,   kVK_ANSI_2),
        CGEvent.key(.up,     kVK_ANSI_2),
        CGEvent.key(.down,   kVK_ANSI_3),
        CGEvent.key(.up,     kVK_ANSI_3),
        CGEvent.key(.down,   kVK_ANSI_4),
        CGEvent.key(.up,     kVK_ANSI_4),
        CGEvent.key(.down,   kVK_ANSI_5),
        CGEvent.key(.up,     kVK_ANSI_5),
        CGEvent.key(.down,   kVK_ANSI_6),
        CGEvent.key(.up,     kVK_ANSI_6),
        CGEvent.key(.down,   kVK_ANSI_7),
        CGEvent.key(.up,     kVK_ANSI_7),
        CGEvent.key(.down,   kVK_ANSI_8),
        CGEvent.key(.up,     kVK_ANSI_8),
        CGEvent.key(.down,   kVK_ANSI_9),
        CGEvent.key(.up,     kVK_ANSI_9),
        CGEvent.key(.down,   kVK_ANSI_0),
        CGEvent.key(.up,     kVK_ANSI_0),
    ]
    
    static let specialCharacters = [
        CGEvent.key(.down,   kVK_ANSI_LeftBracket),
        CGEvent.key(.up,     kVK_ANSI_LeftBracket),
        CGEvent.key(.down,   kVK_ANSI_RightBracket),
        CGEvent.key(.up,     kVK_ANSI_RightBracket),
        CGEvent.key(.down,   kVK_ANSI_Semicolon),
        CGEvent.key(.up,     kVK_ANSI_Semicolon),
        CGEvent.key(.down,   kVK_ANSI_Quote),
        CGEvent.key(.up,     kVK_ANSI_Quote),
        CGEvent.key(.down,   kVK_ANSI_Backslash),
        CGEvent.key(.up,     kVK_ANSI_Backslash),
        CGEvent.key(.down,   kVK_ANSI_Comma),
        CGEvent.key(.up,     kVK_ANSI_Comma),
        CGEvent.key(.down,   kVK_ANSI_Period),
        CGEvent.key(.up,     kVK_ANSI_Period),
        CGEvent.key(.down,   kVK_ANSI_Slash),
        CGEvent.key(.up,     kVK_ANSI_Slash),
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_LeftBracket, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_LeftBracket, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_RightBracket, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_RightBracket, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Semicolon, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Semicolon, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Quote, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Quote, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Backslash, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Backslash, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Comma, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Comma, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Period, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Period, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Slash, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Slash, .maskShift),
        CGEvent.flagsChanged(kVK_Shift),
        CGEvent.key(.down,   kVK_ANSI_Grave),
        CGEvent.key(.up,     kVK_ANSI_Grave),
        CGEvent.key(.down,   kVK_ISO_Section),
        CGEvent.key(.up,     kVK_ISO_Section),
        CGEvent.key(.down,   kVK_ANSI_Minus),
        CGEvent.key(.up,     kVK_ANSI_Minus),
        CGEvent.key(.down,   kVK_ANSI_Equal),
        CGEvent.key(.up,     kVK_ANSI_Equal),
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_1, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_1, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_2, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_2, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_3, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_3, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_4, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_4, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_5, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_5, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_6, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_6, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_7, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_7, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_8, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_8, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_9, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_9, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_0, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_0, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Minus, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Minus, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_Equal, .maskShift),
        CGEvent.key(.up,     kVK_ANSI_Equal, .maskShift),
        CGEvent.flagsChanged(kVK_Shift),
        CGEvent.key(.down,   kVK_Tab),
        CGEvent.key(.up,     kVK_Tab),
        CGEvent.key(.down,   kVK_Return),
        CGEvent.key(.up,     kVK_Return),
    ]
    
    static let Alice: [CGEvent] = [
        CGEvent.flagsChanged(kVK_Shift, .maskShift),
        CGEvent.key(.down,   kVK_ANSI_A, .maskShift),
        CGEvent.flagsChanged(kVK_Shift),
        CGEvent.key(.up,     kVK_ANSI_A),
        CGEvent.key(.down,   kVK_ANSI_L),
        CGEvent.key(.up,     kVK_ANSI_L),
        CGEvent.key(.down,   kVK_ANSI_I),
        CGEvent.key(.up,     kVK_ANSI_I),
        CGEvent.key(.down,   kVK_ANSI_C),
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_C),
        CGEvent.key(.up,     kVK_ANSI_E),
    ]
    
    static let qwerty = [
        CGEvent.key(.down,   kVK_ANSI_Q),
        CGEvent.key(.up,     kVK_ANSI_Q),
        CGEvent.key(.down,   kVK_ANSI_W),
        CGEvent.key(.up,     kVK_ANSI_W),
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_E),
        CGEvent.key(.down,   kVK_ANSI_R),
        CGEvent.key(.up,     kVK_ANSI_R),
        CGEvent.key(.down,   kVK_ANSI_T),
        CGEvent.key(.up,     kVK_ANSI_T),
        CGEvent.key(.down,   kVK_ANSI_Y),
        CGEvent.key(.up,     kVK_ANSI_Y),
    ]
    
    static let capslockAndOption = [
        CGEvent.flagsChanged(kVK_CapsLock, .maskAlphaShift), // Capslock On
        CGEvent.key(.down,   kVK_ANSI_Q, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_Q, .maskAlphaShift),
        CGEvent.key(.down,   kVK_ANSI_W, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_W, .maskAlphaShift),
        CGEvent.key(.down,   kVK_ANSI_E, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_E, .maskAlphaShift),
        CGEvent.flagsChanged(kVK_RightOption, [.maskAlphaShift, .maskAlternate]),
        CGEvent.flagsChanged(kVK_RightOption, .maskAlphaShift),
    ]
    
    static let capslockMixedAndOption = [
        CGEvent.flagsChanged(kVK_CapsLock, .maskAlphaShift), // Capslock On
        CGEvent.key(.down,   kVK_ANSI_Q, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_Q, .maskAlphaShift),
        CGEvent.key(.down,   kVK_ANSI_W, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_W, .maskAlphaShift),
        CGEvent.flagsChanged(kVK_CapsLock),                  // Capslock Off
        CGEvent.key(.down,   kVK_ANSI_E),
        CGEvent.key(.up,     kVK_ANSI_E),
        CGEvent.flagsChanged(kVK_CapsLock, .maskAlphaShift), // Capslock On
        CGEvent.key(.down,   kVK_ANSI_R, .maskAlphaShift),
        CGEvent.key(.up,     kVK_ANSI_R, .maskAlphaShift),
        CGEvent.flagsChanged(kVK_CapsLock),                  // Capslock Off
        CGEvent.flagsChanged(kVK_RightOption, .maskAlternate),
        CGEvent.flagsChanged(kVK_RightOption),
    ]
    
    static let fnA = [
        CGEvent.flagsChanged(kVK_Function, .maskSecondaryFn),
        CGEvent.key(.down,   kVK_ANSI_A, .maskSecondaryFn),
        CGEvent.key(.up,     kVK_ANSI_A, .maskSecondaryFn),
        CGEvent.flagsChanged(kVK_Function),
    ]
    
    static let controlA = [
        CGEvent.flagsChanged(kVK_Control, .maskControl),
        CGEvent.key(.down,   kVK_ANSI_A, .maskControl),
        CGEvent.flagsChanged(kVK_Control),
        CGEvent.key(.up,     kVK_ANSI_A),
    ]
    
    static let optionA = [
        CGEvent.flagsChanged(kVK_Option, .maskAlternate),
        CGEvent.key(.down,   kVK_ANSI_A, .maskAlternate),
        CGEvent.key(.up,     kVK_ANSI_A, .maskAlternate),
        CGEvent.flagsChanged(kVK_Option),
    ]
    
    static let commandA = [
        CGEvent.flagsChanged(kVK_Command, .maskCommand),
        CGEvent.key(.down,   kVK_ANSI_A, .maskCommand),
        CGEvent.flagsChanged(kVK_Command),
        CGEvent.key(.up,     kVK_ANSI_A),
    ]
    
    static let leftArrow = [
        CGEvent.key(.down,   kVK_LeftArrow, [.maskSecondaryFn, .maskNumericPad]),
        CGEvent.key(.up,     kVK_LeftArrow, [.maskSecondaryFn, .maskNumericPad]),
    ]
    static let rightArrow = [
        CGEvent.key(.down,   kVK_RightArrow, [.maskSecondaryFn, .maskNumericPad]),
        CGEvent.key(.up,     kVK_RightArrow, [.maskSecondaryFn, .maskNumericPad]),
    ]
    static let upArrow = [
        CGEvent.key(.down,   kVK_UpArrow, [.maskSecondaryFn, .maskNumericPad]),
        CGEvent.key(.up,     kVK_UpArrow, [.maskSecondaryFn, .maskNumericPad]),
    ]
    static let downArrow = [
        CGEvent.key(.down,   kVK_DownArrow, [.maskSecondaryFn, .maskNumericPad]),
        CGEvent.key(.up,     kVK_DownArrow, [.maskSecondaryFn, .maskNumericPad]),
    ]
    
    static let escape = [
        CGEvent.key(.down,   kVK_Escape),
        CGEvent.key(.up,     kVK_Escape),
    ]
    
    static let f1 = [
        CGEvent.key(.down,   kVK_F1, .maskSecondaryFn),
        CGEvent.key(.up,     kVK_F1, .maskSecondaryFn),
    ]
    
    static let mouseDown = [
        CGEvent.mouseDown
    ]
    
    static let crtlOptZ = [
        CGEvent.flagsChanged(kVK_Option, .maskAlternate),
        CGEvent.flagsChanged(kVK_Control, [.maskControl, .maskAlternate]),
        CGEvent.key(.down,   kVK_ANSI_Z, [.maskControl, .maskAlternate]),
        CGEvent.key(.up,     kVK_ANSI_Z, [.maskControl, .maskAlternate]),
        CGEvent.flagsChanged(kVK_Option, .maskControl),
        CGEvent.flagsChanged(kVK_Control),
    ]
}

private enum Output {
    static func backspaces(count: Int) -> [InputEvent] {
        [
            InputEvent.key(.down, kVK_Delete),
            InputEvent.key(.up,   kVK_Delete),
        ] * count
    }
    
    static let Hello: [InputEvent] = [
        .flagsChanged(kVK_Shift, .maskShift),
        .key(.down,   kVK_ANSI_H, .maskShift),
        .key(.up,     kVK_ANSI_H, .maskShift),
        .flagsChanged(kVK_Shift),
        .key(.down,   kVK_ANSI_E),
        .key(.up,     kVK_ANSI_E),
        .key(.down,   kVK_ANSI_L),
        .key(.up,     kVK_ANSI_L),
        .key(.down,   kVK_ANSI_L),
        .key(.up,     kVK_ANSI_L),
        .key(.down,   kVK_ANSI_O),
        .key(.up,     kVK_ANSI_O),
    ]
    
    static let space: [InputEvent] = [
        .key(.down,   kVK_Space),
        .key(.up,     kVK_Space),
    ]
    
    static let World: [InputEvent] = [
        .flagsChanged(kVK_Shift, .maskShift),
        .key(.down,   kVK_ANSI_W, .maskShift),
        .key(.up,     kVK_ANSI_W, .maskShift),
        .flagsChanged(kVK_Shift),
        .key(.down,   kVK_ANSI_O),
        .key(.up,     kVK_ANSI_O),
        .key(.down,   kVK_ANSI_R),
        .key(.up,     kVK_ANSI_R),
        .key(.down,   kVK_ANSI_L),
        .key(.up,     kVK_ANSI_L),
        .key(.down,   kVK_ANSI_D),
        .key(.up,     kVK_ANSI_D),
    ]
    
    static var Hello_World: [InputEvent] {
        Hello + space + World
    }
    
    static let Alice: [InputEvent] = [
        .flagsChanged(kVK_Shift, .maskShift),
        .key(.down,   kVK_ANSI_A, .maskShift),
        .key(.up,     kVK_ANSI_A, .maskShift),
        .flagsChanged(kVK_Shift),
        .key(.down,   kVK_ANSI_L),
        .key(.up,     kVK_ANSI_L),
        .key(.down,   kVK_ANSI_I),
        .key(.up,     kVK_ANSI_I),
        .key(.down,   kVK_ANSI_C),
        .key(.up,     kVK_ANSI_C),
        .key(.down,   kVK_ANSI_E),
        .key(.up,     kVK_ANSI_E),
    ]
    
    static var Hello_Alice: [InputEvent] {
        Hello + space + Alice
    }
    
    static let commandC: [InputEvent] = [
        .flagsChanged(kVK_Command, .maskCommand),
        .key(.down,   kVK_ANSI_C, .maskCommand),
        .key(.up,     kVK_ANSI_C, .maskCommand),
        .flagsChanged(kVK_Command),
    ]
    
    static let commandV: [InputEvent] = [
        .flagsChanged(kVK_Command, .maskCommand),
        .key(.down,   kVK_ANSI_V, .maskCommand),
        .key(.up,     kVK_ANSI_V, .maskCommand),
        .flagsChanged(kVK_Command),
    ]
    
    static var copyPaste: [InputEvent] { commandC + commandV }
    
    static let capslock: [InputEvent] = [
        .key(.down,   kVK_ANSI_Q, .maskAlphaShift),
        .key(.up,     kVK_ANSI_Q, .maskAlphaShift),
        .key(.down,   kVK_ANSI_W, .maskAlphaShift),
        .key(.up,     kVK_ANSI_W, .maskAlphaShift),
        .key(.down,   kVK_ANSI_E, .maskAlphaShift),
        .key(.up,     kVK_ANSI_E, .maskAlphaShift),
    ]
    
    static let capslockMixed: [InputEvent] = [
        .key(.down,   kVK_ANSI_Q, .maskAlphaShift),
        .key(.up,     kVK_ANSI_Q, .maskAlphaShift),
        .key(.down,   kVK_ANSI_W, .maskAlphaShift),
        .key(.up,     kVK_ANSI_W, .maskAlphaShift),
        .key(.down,   kVK_ANSI_E),
        .key(.up,     kVK_ANSI_E),
        .key(.down,   kVK_ANSI_R, .maskAlphaShift),
        .key(.up,     kVK_ANSI_R, .maskAlphaShift),
    ]
}

private enum TestData {
    static let engCharacters       = #"qwertyuiopasdfghjklzxcvbnm QWERTYUIOPASDFGHJKLZXCVBNM [];'\,./ {}:"|<>? §1234567890-= ±!@#$%^&*()_+"#
    static let rusCharacters       = #"йцукенгшщзфывапролдячсмить ЙЦУКЕНГШЩЗФЫВАПРОЛДЯЧСМИТЬ хъжэёбю/ ХЪЖЭЁБЮ? >1234567890-= <!"№%:,.;()_+"#
    
    static let engBeginsWithNumeric = "12345qwert"
    static let rusBeginsWithNumeric = "12345йцуке"
    static let engBeginsWithSpace = "   qwert"
    static let rusBeginsWithSpace = "   йцуке"
    static let engBeginsWithEmoji = "👀qwert"
    static let rusBeginsWithEmoji = "👀йцуке"
    
    static let noLetters = "123 ✍️"
    
    static let lowercased           = "qwerty 🤡 йцукен"
    static let uppercased           = "QWERTY 🤡 ЙЦУКЕН"
    static let mixcasedCapitalized  = "QWerTY 🤡 ЙЦукЕН"
    static let mixcased             = "qwERty 🤡 йцУКен"
}
