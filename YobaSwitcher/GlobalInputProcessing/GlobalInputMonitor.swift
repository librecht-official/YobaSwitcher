//
//  GlobalInputMonitor.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

protocol GlobalInputMonitorProtocol: AnyObject {
    func start()
}

protocol GlobalInputHandler<Event> {
    associatedtype Event: HIDEvent
    
    func handleEvent(event: Event, proxy: CGEventTapProxy) -> Event?
}

// Tracks specific input events such as keystrokes and mouse clicks
final class GlobalInputMonitor: GlobalInputMonitorProtocol {
    let handler: any GlobalInputHandler<CGEvent>
    private var eventTap: CFMachPort?
    
    init(handler: any GlobalInputHandler<CGEvent>) {
        self.handler = handler
    }
    
    func start() {
        let mask: CGEventMaskSet = [.keyDown, .keyUp, .flagsChanged, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .tailAppendEventTap,
            options: .defaultTap,
            eventsOfInterest: mask.rawValue,
            callback: { proxy, eventType, event, ctx in
                guard let context = ctx else { return Unmanaged.passUnretained(event) }
                let weakSelf = Unmanaged<GlobalInputMonitor>.fromOpaque(context).takeUnretainedValue()
                return weakSelf.handleEventTapCallback(proxy, eventType, event).map(Unmanaged.passUnretained)
            },
            userInfo: context
        ) else {
            Log.inputProcessing.critical("Event tap is not created")
            return
        }
        self.eventTap = eventTap
        
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
    }
    
    private func handleEventTapCallback(_ proxy: CGEventTapProxy, _ eventType: CGEventType, _ event: CGEvent) -> CGEvent? {
        #if DEBUG
        if Log.isRecording {
            Log.recording.debug("\(event),")
        }
        #endif
        
        if eventType == .tapDisabledByTimeout {
            Log.inputProcessing.info("Event tap disabled by timeout. Re-enabling")
            CGEvent.tapEnable(tap: eventTap!, enable: true)
        }
        return handler.handleEvent(event: event, proxy: proxy)
    }
}
