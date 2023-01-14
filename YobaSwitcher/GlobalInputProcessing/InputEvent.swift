//
//  InputEvent.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

/// A value type that represents input event
enum InputEvent: Equatable {
    case keyDown(Keystroke)
    case keyUp(Keystroke)
    /// Key changed event for a modifier or status key.
    ///
    /// `keyDown` is important only when constructing `CGEvent` to post. Incoming `CGEvent`s doesn't have this information. You can understant direction only by checking flags. For example 'Option down' event has `maskAlternate` flag and 'Option up' doesn't.
    case flagsChanged(Keystroke, keyDown: Bool = false)
    case mouseDown
}

// MARK: - Matchable

extension InputEvent: Matchable {
    func matches(_ rhs: InputEvent) -> Bool {
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

// MARK: - CustomStringConvertible

extension InputEvent: CustomStringConvertible {
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

// MARK: - CustomDebugStringConvertible

extension InputEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .keyDown(keystroke):
            return debugString(from: keystroke, direction: "↓")
        
        case .keyUp(let keystroke):
            return debugString(from: keystroke, direction: "↑")
            
        case let .flagsChanged(keystroke, keyDown):
            return debugString(from: keystroke, direction: keyDown ? "↓" : "↑")
            
        case .mouseDown:
            return "🐁[↓]"
        }
    }
    
    private func debugString(from keystroke: Keystroke, direction: String) -> String {
        var mods: [String] = [direction, keystroke.flags.debugDescription]
        if keystroke.isAutorepeat {
            mods.append("AR")
        }
        return "\(keystroke.keyCode.debugDescription)(\(mods.joined(separator: ",")))"
    }
}

// MARK: - InputEvent to CGEvent

extension CGEvent {
    static func fromInputEvent(_ inputEvent: InputEvent) -> CGEvent? {
        switch inputEvent {
        case let .keyDown(keystroke):
            return CGEvent.fromKeystrokeDown(keystroke)
            
        case let .keyUp(keystroke):
            return CGEvent.fromKeystrokeUp(keystroke)
            
        case let .flagsChanged(keystroke, keyDown):
            let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keystroke.keyCode.cgKeyCode, keyDown: keyDown)
            cgEvent?.flags = keystroke.flags
            return cgEvent
            
        case .mouseDown:
            let cgEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)!
            return cgEvent
        }
    }
    
    static func fromKeystrokeDown(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keystroke.keyCode.cgKeyCode, keyDown: true)
        cgEvent?.flags = keystroke.flags
        return cgEvent
    }
    
    static func fromKeystrokeUp(_ keystroke: Keystroke) -> CGEvent? {
        let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keystroke.keyCode.cgKeyCode, keyDown: false)
        cgEvent?.flags = keystroke.flags
        return cgEvent
    }
}
