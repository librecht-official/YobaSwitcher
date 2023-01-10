//
//  GlobalInputMonitor.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

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
        // TODO: Use CGEventMaskSet
        var rawMask = (1 << CGEventType.keyDown.rawValue)
        rawMask |= (1 << CGEventType.keyUp.rawValue)
        rawMask |= (1 << CGEventType.flagsChanged.rawValue)
        rawMask |= (1 << CGEventType.leftMouseDown.rawValue)
        rawMask |= (1 << CGEventType.rightMouseDown.rawValue)
        rawMask |= (1 << CGEventType.otherMouseDown.rawValue)
        let mask = CGEventMask(rawMask)
        
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .tailAppendEventTap,
            options: .defaultTap, // listenOnly defaultTap
            eventsOfInterest: mask,
            callback: { proxy, eventType, event, ctx in
                guard let context = ctx else { return Unmanaged.passUnretained(event) }
                let weakSelf = Unmanaged<GlobalInputMonitor>.fromOpaque(context).takeUnretainedValue()
                return weakSelf.handleEventTapCallback(proxy, eventType, event).map(Unmanaged.passUnretained)
            },
            userInfo: context
        ) else {
            print("Event tap is not created")
            return
        }
        self.eventTap = eventTap
        
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func handleEventTapCallback(_ proxy: CGEventTapProxy, _ eventType: CGEventType, _ event: CGEvent) -> CGEvent? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if eventType != event.type {
            print("hmmmm...")
        }
        
        switch eventType {
        case .keyDown:
            print("keyDown: \(keyCode)")
            return handler?.handleKeyDown(event: event, proxy: proxy)
        
        case .keyUp:
            print("keyUp: \(keyCode), flags: \(event.flags)")
            return handler?.handleKeyUp(event: event, proxy: proxy)
            
        case .flagsChanged:
            print("flagsChanged: \(keyCode), flags: \(event.flags)")
            return handler?.handleFlagsChange(event: event, proxy: proxy)
            
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return handler?.handleMouseDown(event: event, proxy: proxy)
            
        case .tapDisabledByTimeout:
            print("tapDisabledByTimeout")
            CGEvent.tapEnable(tap: eventTap!, enable: true)
            
        default:
            break
        }
        
        return event
    }
}
