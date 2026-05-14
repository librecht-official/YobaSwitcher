//
//  Created by Vladislav Librecht on 12.05.2026
//

import Testing
import Cocoa
import Carbon
@testable import YobaSwitcher

@MainActor
struct GlobalInputProcessingTests {
    let events = SystemEventsRecorder()
    let pasteboard = PasteboardMock()
    
    let processor: GlobalInputProcessingController
    
    init() {
        StaticDependency.systemEvents = events
        StaticDependency.pasteboard = pasteboard
        
        let tisAPIMock = TISAPIMock()
        
        let tisManager = DefaultTextInputSourceManager(
            distributedNotificationCenter: tisAPIMock,
            tis: tisAPIMock
        )
        let systemWide = SystemWide<AXUIElement>()
        
        self.processor = GlobalInputProcessingController(
            selectedTextManager: SystemWideSelectedTextManager(tisManager: tisManager, systemWide: systemWide),
            inputSourceManager: tisManager
        )
    }
    
    // MARK: Typing traslation
    
    /// Type all character-producing keys, 'space', 'tab' and 'return' then press 'right option'. It should delete all characters, switch input source and retype the same keys
    @Test
    func typingAllCharacterProducingKeys() {
        // given
        let input = Events.allCharacterProducing + Events.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let output = Events.backspaces(count: (Events.allCharacterProducing.count / 2)) + Events.allCharacterProducing
        #expect(events.recordedEvents == output)
    }
    
    // TODO: With Backspaces
    
    // MARK: - Selected Text switching
    
    /// Type "hello world", then delete 2 characters and types "d", so the result is "hello word", then press Option. It should delete 10 characters, switch input source and retype "hello word"
    
    
    /// Switch selected text English -> Russian. Base case
    @Test
    func switchSelectedText_EngRus() {
        // given
        events.pasteboard = pasteboard
        pasteboard._selectedText = TestData.engCharacters
        let input = Events.option
        // when
        input.forEach(processInputEvent)
        // then
        // selected text should be switched to russian
        #expect(pasteboard._selectedText == TestData.rusCharacters)
        // pasteboard should have the same content as before switching
        #expect(pasteboard.pasteboardItems == pasteboard._initialItems)
    }
    
    // TODO: Test when selected/typed text start with 'space'
    
    // TODO: Test when selected text has capital letters
    
    // TODO: Test when first char is space or other non-letter
    
    // MARK: Helpers
    
    func processInputEvent(_ event: InputEvent) {
        let proxyStub = EventTapProxyStub()
        let tapProxy = CGEventTapProxy(Unmanaged.passUnretained(proxyStub).toOpaque())
        let cgEvent = CGEvent.fromInputEvent(event)!
        
        switch event {
        case .keyDown:
            processor.handleKeyDown(event: cgEvent, proxy: tapProxy)
        case .keyUp:
            processor.handleKeyUp(event: cgEvent, proxy: tapProxy)
        case .flagsChanged:
            processor.handleFlagsChange(event: cgEvent, proxy: tapProxy)
        case .mouseDown:
            processor.handleMouseDown(event: cgEvent, proxy: tapProxy)
        }
    }
}

private enum TestData {
    
    static let engCharacters       = #"qwertyuiopasdfghjklzxcvbnm QWERTYUIOPASDFGHJKLZXCVBNM [];'\,./ {}:"|<>? §1234567890-= ±!@#$%^&*()_+"#
    static let rusCharacters       = #"йцукенгшщзфывапролдячсмить ЙЦУКЕНГШЩЗФЫВАПРОЛДЯЧСМИТЬ хъжэёбю/ ХЪЖЭЁБЮ? >1234567890-= <!"№%:,.;()_+"#
}
