//
//  Created by Vladislav Librecht on 12.05.2026
//

import CoreGraphics

protocol SystemEventsAPI {
    func postEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy)
    
    func postEvent(_ inputEvent: InputEvent, at location: CGEventTapLocation)
}

struct SystemEvents: SystemEventsAPI {
    static let `default` = SystemEvents()
    
    func postEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) {
        Log.debug("Posting event: \(inputEvent) using proxy")
        let event = CGEvent.fromInputEvent(inputEvent)
        event?.tapPostEvent(proxy)
    }
    
    func postEvent(_ inputEvent: InputEvent, at location: CGEventTapLocation) {
        Log.debug("Posting event: \(inputEvent)")
        let event = CGEvent.fromInputEvent(inputEvent)
        event?.post(tap: location)
    }
}

extension StaticDependency {
    #if TEST
    static var systemEvents: SystemEventsAPI = SystemEvents.default
    #else
    static let systemEvents = SystemEvents.default
    #endif
}
