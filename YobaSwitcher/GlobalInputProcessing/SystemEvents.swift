//
//  Created by Vladislav Librecht on 12.05.2026
//

import CoreGraphics

struct SystemEvents {
    static let `default` = SystemEvents(
        postEventWithProxy: { inputEvent, proxy in
            Log.debug("Posting event: \(inputEvent) using proxy")
            let event = CGEvent.fromInputEvent(inputEvent)
            event?.tapPostEvent(proxy)
        },
        postEvent: { inputEvent, location in
            Log.debug("Posting event: \(inputEvent)")
            let event = CGEvent.fromInputEvent(inputEvent)
            event?.post(tap: location)
        })
    
    private let _postEventWithProxy: (InputEvent, CGEventTapProxy) -> Void
    private let _postEvent: (InputEvent, CGEventTapLocation) -> Void
    
    init(
        postEventWithProxy: @escaping (InputEvent, CGEventTapProxy) -> Void,
        postEvent: @escaping (InputEvent, CGEventTapLocation) -> Void) {
        self._postEventWithProxy = postEventWithProxy
        self._postEvent = postEvent
    }
    
    func postEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) {
        _postEventWithProxy(inputEvent, proxy)
    }
    
    func postEvent(_ inputEvent: InputEvent, at location: CGEventTapLocation) {
        _postEvent(inputEvent, location)
    }
}
