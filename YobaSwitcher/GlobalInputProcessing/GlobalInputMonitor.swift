//
//  GlobalInputMonitor.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

protocol GlobalInputMonitorProtocol: AnyObject {
    var handler: GlobalInputHandler? { get set }
    
    func start()
}

protocol GlobalInputHandler: AnyObject {
    func handleKeyDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleKeyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleFlagsChange(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
    
    func handleMouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent?
}

// Tracks specific input events such as keystrokes and mouse clicks
final class GlobalInputMonitor: GlobalInputMonitorProtocol {
    weak var handler: GlobalInputHandler?
    private var eventTap: CFMachPort?
    
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
        let recording = true
        switch eventType {
        case .keyDown:
            if recording {
                Log.recording.debug("\(InputEvent.keyDown(.init(event: event))),")
            }
            return handler?.handleKeyDown(event: event, proxy: proxy)
        
        case .keyUp:
            if recording {
                Log.recording.debug("\(InputEvent.keyUp(.init(event: event))),")
            }
            return handler?.handleKeyUp(event: event, proxy: proxy)
            
        case .flagsChanged:
            if recording {
                Log.recording.debug("\(InputEvent.flagsChanged(.init(event: event))),")
            }
            return handler?.handleFlagsChange(event: event, proxy: proxy)
            
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            if recording {
                Log.recording.debug("\(InputEvent.mouseDown),")
            }
            return handler?.handleMouseDown(event: event, proxy: proxy)
            
        case .tapDisabledByTimeout:
            Log.inputProcessing.info("Event tap disabled by timeout. Re-enabling")
            CGEvent.tapEnable(tap: eventTap!, enable: true)
            
        default:
            break
        }
        
        return event
    }
}
