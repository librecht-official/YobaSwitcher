//
//  GlobalInputMonitor.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

// sourcery: AutoMockable
protocol GlobalInputMonitorProtocol: AnyObject {
    var handler: GlobalInputMonitorHandler? { get set }
    
    func start()
}

protocol GlobalInputMonitorHandler: AnyObject {
    func handleKeyDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleKeyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleFlagsChange(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleMouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
}

// Tracks specific input events such as keystrokes and mouse clicks
final class GlobalInputMonitor: GlobalInputMonitorProtocol {
    weak var handler: GlobalInputMonitorHandler?
    private var eventTap: CFMachPort?
    
    func start() {
        let mask: CGEventMaskSet = [.keyDown, .keyUp, .flagsChanged, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .tailAppendEventTap,
            options: .defaultTap, // listenOnly defaultTap
            eventsOfInterest: mask.rawValue,
            callback: { proxy, eventType, event, ctx in
                guard let context = ctx else { return Unmanaged.passUnretained(event) }
                let weakSelf = Unmanaged<GlobalInputMonitor>.fromOpaque(context).takeUnretainedValue()
                return weakSelf.handleEventTapCallback(proxy, eventType, event).map(Unmanaged.passUnretained)
            },
            userInfo: context
        ) else {
            Log.critical("Event tap is not created")
            return
        }
        self.eventTap = eventTap
        
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func handleEventTapCallback(_ proxy: CGEventTapProxy, _ eventType: CGEventType, _ event: CGEvent) -> CGEvent? {
        switch eventType {
        case .keyDown:
            Log.info(InputEvent.keyDown(.init(event: event)), terminator: ",\n", hashtags: [.recording])
            return handler?.handleKeyDown(event: event, proxy: proxy)
        
        case .keyUp:
            Log.info(InputEvent.keyUp(.init(event: event)), terminator: ",\n", hashtags: [.recording])
            return handler?.handleKeyUp(event: event, proxy: proxy)
            
        case .flagsChanged:
            Log.info(InputEvent.flagsChanged(.init(event: event)), terminator: ",\n", hashtags: [.recording])
            return handler?.handleFlagsChange(event: event, proxy: proxy)
            
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            Log.info(InputEvent.mouseDown, terminator: ",\n", hashtags: [.recording])
            return handler?.handleMouseDown(event: event, proxy: proxy)
            
        case .tapDisabledByTimeout:
            Log.info("tapDisabledByTimeout")
            CGEvent.tapEnable(tap: eventTap!, enable: true)
            
        default:
            break
        }
        
        return event
    }
}
