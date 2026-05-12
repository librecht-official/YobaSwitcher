//
//  Created by Vladislav Librecht on 12.05.2026
//

import Testing
//import Mockingbird
import Cocoa
import Carbon
@testable import YobaSwitcher

@MainActor
//@Suite("Integration tests of global input events processing")
struct GlobalInputProcessingTests {
    let events = SystemEventsRecorder()
    
    let processor: GlobalInputProcessingController
    
    init() {
        
        let tisAPIMock = TISAPIMock()
        
        let tisManager = DefaultTextInputSourceManager(
            distributedNotificationCenter: tisAPIMock,
            tis: tisAPIMock
        )
        let systemWide = SystemWide<AXUIElement>()
        
        let systemEvents = SystemEvents.mock(recorder: events)
        DI.systemEvents = systemEvents
        
//        DI.pasteboard
        
        self.processor = GlobalInputProcessingController(
            selectedTextManager: SystemWideSelectedTextManager(tisManager: tisManager, systemWide: systemWide),
            inputSourceManager: tisManager,
            systemEvents: systemEvents
        )
    }
    
    /// Type all character-producing keys, 'space', 'tab' and 'return' then press 'right option'. It should delete all characters, switch input source and retype the same keys
    @Test("All character-producing keys")
    func allCharacterProducingKeys() {
        // given
        let input = Events.allCharacterProducing + Events.rightOption
        // when
        input.forEach(processInputEvent)
        // then
        let output = Events.backspaces(count: (Events.allCharacterProducing.count / 2)) + Events.allCharacterProducing
        #expect(events.recordedEvents == output)
    }
    
    @Test
    func selectedText() {
        let input = Events.option
        
        input.forEach(processInputEvent)
        
        
    }
    
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

final class TISRefMock: TextInputSourceReference {
    let id: String
    var isSelected: Bool
    weak var tisAPI: TISAPIMock?
    
    init(id: String = "en", isSelected: Bool = false, tisAPI: TISAPIMock?) {
        self.id = id
        self.isSelected = isSelected
        self.tisAPI = tisAPI
    }
    
    func value<T>(key: CFString) -> T? {
        switch key {
        case kTISPropertyInputSourceID:
            return id as? T
        case kTISPropertyInputSourceIsSelected:
            return isSelected as? T
        default:
            return nil
        }
    }
    
    func select() {
        tisAPI?.select(TextInputSource(self))
        isSelected = true
    }
    
    static func == (lhs: TISRefMock, rhs: TISRefMock) -> Bool {
        lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}

final class TISAPIMock: TextInputSourceAPI, DistributedNotificationCenterProtocol {
    var data: [TISRefMock] = []
    var observer: Any?, selector: Selector?
    
    init() {
        self.data = [
            TISRefMock(id: "en", isSelected: true, tisAPI: self),
            TISRefMock(id: "ru", isSelected: false, tisAPI: self),
        ]
    }
    
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        let tisRef = data.first(where: \.isSelected)!
        return TextInputSource(tisRef)
    }
    
    func inputSource(forLanguage id: String) -> TextInputSource {
        let tisRef = data.first(where: { $0.id == id })!
        return TextInputSource(tisRef)
    }
    
    func inputSourceList(filter: [CFString : Any]) -> [TextInputSource] {
        data.map { TextInputSource($0) }
    }
    
    func select(_ source: TextInputSource) {
        data.forEach {
            if $0.id != source.id {
                $0.isSelected = false
            }
        }
        guard let observer = observer as? AnyObject, let selector else {
            assertionFailure("No observer and selector")
            return
        }
        _ = observer.perform(selector, with: "test-notification")
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name?, object: String?, suspensionBehavior: DistributedNotificationCenter.SuspensionBehavior) {
        self.observer = observer
        self.selector = selector
    }
    
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: String?) {
        
    }
}

extension SystemEvents {
    static func mock(recorder: SystemEventsRecorder) -> SystemEvents {
        SystemEvents(
            postEventWithProxy: { event, proxy in
                recorder.recordedEvents.append(event)
            },
            postEvent: { event, location in
                recorder.recordedEvents.append(event)
            })
    }
}

class SystemEventsRecorder {
    var recordedEvents: [InputEvent] = []
}
