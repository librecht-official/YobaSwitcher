//
//  KeystrokeEvent.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

enum KeystrokeEvent: Equatable {
    case keyDown(Keystroke)
    case keyUp(Keystroke)
    case flagsChanged(Keystroke, keyDown: Bool = false)
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
            
        case let .flagsChanged(ks, keyDown):
            let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(ks.keyCode), keyDown: keyDown)
            cgEvent?.flags = ks.flags
            return cgEvent
            
        case .mouseDown:
            let cgEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)!
            return cgEvent
        }
    }
    
    static func fromKeystrokeDown(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keystroke.keyCode), keyDown: true)
        cgEvent?.flags = keystroke.flags
        return cgEvent
    }
    
    static func fromKeystrokeUp(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keystroke.keyCode), keyDown: false)
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
        case let .flagsChanged(keystroke, keyDown):
            return ".flagsChanged(\(keystroke), keyDown: \(keyDown))"
        case .mouseDown:
            return ".mouseDown"
        }
    }
}

extension KeystrokeEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .keyDown(keystroke):
            var mods: [String] = ["↓", keystroke.flags.debugDescription]
            if keystroke.isAutorepeat {
                mods.append("R")
            }
            return "\(KeyCode.string(keystroke.keyCode))[\(mods.joined(separator: ","))]"
        
        case .keyUp(let keystroke):
            return "\(KeyCode.string(keystroke.keyCode))[↑]"
            
        case let .flagsChanged(keystroke, keyDown):
            return "\(KeyCode.string(keystroke.keyCode))[\(keyDown ? "↓" : "↑")]"
            
        case .mouseDown:
            return "🐁[↓]"
        }
    }
}

enum KeyCode {
    static func string(_ keyCode: Int) -> String {
        keyCodesToString[keyCode] ?? String(keyCode)
    }
}

private let keyCodesToString: [Int: String] = [
    // Supplement as necessary
    kVK_ANSI_H: "H",
    kVK_ANSI_E: "E",
    kVK_ANSI_L: "L",
    kVK_ANSI_O: "O",
    kVK_ANSI_W: "W",
    kVK_ANSI_R: "R",
    kVK_ANSI_D: "D",
    kVK_Delete: "⌫",
    kVK_ForwardDelete: "F⌫",
    kVK_Space: "␣",
]

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
