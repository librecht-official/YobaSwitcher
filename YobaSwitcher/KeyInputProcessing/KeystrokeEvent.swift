//
//  KeystrokeEvent.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import CoreGraphics

enum KeystrokeEvent: Equatable {
    case keyDown(Keystroke)
    case keyUp(Keystroke)
    case flagsChanged(Keystroke)
    case mouseDown
}

struct Keystroke: Equatable {
    let keyCode: Int
    let flags: CGEventFlags
    let isAutorepeat: Bool
    
    init(keyCode: Int, flags: CGEventFlags = .maskNonCoalesced, isAutorepeat: Bool = false) {
        self.keyCode = keyCode
        self.flags = flags
        self.isAutorepeat = isAutorepeat
    }
    
    init(event: CGEvent) {
        self.keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        self.flags = event.flags
        self.isAutorepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
    }
}

extension CGEvent {
    static func fromKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent) -> CGEvent? {
        switch keystrokeEvent {
        case let .keyDown(ks):
            return CGEvent.fromKeystrokeDown(ks)
            
        case let .keyUp(ks):
            return CGEvent.fromKeystrokeUp(ks)
            
        case let .flagsChanged(ks):
            let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(ks.keyCode), keyDown: false)
            cgEvent?.flags = ks.flags
            return cgEvent
            
        case .mouseDown:
            let cgEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)!
            return cgEvent
        }
    }
    
    static func fromKeystrokeDown(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent.keyDown(CGKeyCode(keystroke.keyCode))
        cgEvent?.flags = keystroke.flags
        return cgEvent
    }
    
    static func fromKeystrokeUp(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent.keyUp(CGKeyCode(keystroke.keyCode))
        cgEvent?.flags = keystroke.flags
        return cgEvent
    }
}

extension KeystrokeEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case let .keyDown(keystroke):
            return ".keyDown(\(keystroke))"
        case .keyUp(let keystroke):
            return ".keyUp(\(keystroke))"
        case .flagsChanged(let keystroke):
            return ".flagsChanged(\(keystroke))"
        case .mouseDown:
            return ".mouseDown"
        }
    }
}

extension Keystroke: CustomStringConvertible {
    var description: String {
        var arguments: [String] = ["keyCode: \(keyCode)"]
        if flags != .maskNonCoalesced {
            arguments.append("flags: \(flags)")
        }
        if isAutorepeat != false {
            arguments.append("isAutorepeat: \(isAutorepeat)")
        }
        return "Keystroke(\(arguments.joined(separator: ", ")))"
    }
}