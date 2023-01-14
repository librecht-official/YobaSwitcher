//
//  KeystrokeEvent.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

enum KeystrokeEvent: Equatable { // TODO: InputEvent
    case keyDown(Keystroke)
    case keyUp(Keystroke)
    /// Key changed event for a modifier or status key.
    ///
    /// `keyDown` is important only when constructing `CGEvent` to post. Incoming `CGEvent`s doesn't have this information. You can understant direction only by checking flags. For example 'Option down' event has `maskAlternate` flag and 'Option up' doesn't.
    case flagsChanged(Keystroke, keyDown: Bool = false)
    case mouseDown
}

extension KeystrokeEvent: Matchable {
    func matches(_ rhs: KeystrokeEvent) -> Bool {
        switch (self, rhs) {
        case let (.keyDown(ks1), .keyDown(ks2)):
            return ks1.matches(ks2)
            
        case let (.keyUp(ks1), .keyUp(ks2)):
            return ks1.matches(ks2)
            
        case let (.flagsChanged(ks1, _), .flagsChanged(ks2, _)):// Ignore keyDown intentionally
            return ks1.matches(ks2)
            
        case (.mouseDown, .mouseDown):
            return true
            
        default:
            return false
        }
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
            var mods: [String] = ["↑", keystroke.flags.debugDescription]
            if keystroke.isAutorepeat {
                mods.append("R")
            }
            return "\(KeyCode.string(keystroke.keyCode))[\(mods.joined(separator: ","))]"
            
        case let .flagsChanged(keystroke, keyDown):
            var mods: [String] = [keyDown ? "↓" : "↑", keystroke.flags.debugDescription]
            if keystroke.isAutorepeat {
                mods.append("R")
            }
            return "\(KeyCode.string(keystroke.keyCode))[\(mods.joined(separator: ","))]"
            
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
