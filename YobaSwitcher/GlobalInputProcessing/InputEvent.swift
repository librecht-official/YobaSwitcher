//
//  InputEvent.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import CoreGraphics

/// A value type that represents input event
enum InputEvent: Equatable {
    enum Direction {
        case up, down
    }
    
    case key(Direction, Keystroke)
    
    /// 'Key changed' event for a modifier or status key.
    case flagsChanged(Keystroke)
    
    case mouseDown
    
    // MARK: Convenience initializers
    
    static func key(_ keyCode: KeyCode, _ direction: Direction, _ flags: CGEventFlags = []) -> InputEvent {
        .key(direction, Keystroke(keyCode, flags: flags))
    }
    
    static func shift(_ direction: Direction, _ flags: CGEventFlags = []) -> InputEvent {
        switch direction {
        case .down:
            return .flagsChanged(Keystroke(.shift, flags: flags.union(.maskShift)))
        case .up:
            return .flagsChanged(Keystroke(.shift, flags: flags))
        }
    }
    
    static func option(_ direction: Direction, _ flags: CGEventFlags = []) -> InputEvent {
        switch direction {
        case .down:
            return .flagsChanged(Keystroke(.option, flags: flags.union(.maskAlternate)))
        case .up:
            return .flagsChanged(Keystroke(.option, flags: flags))
        }
    }
    
    static func command(_ direction: Direction, _ flags: CGEventFlags = []) -> InputEvent {
        switch direction {
        case .down:
            return .flagsChanged(Keystroke(.command, flags: flags.union(.maskCommand)))
        case .up:
            return .flagsChanged(Keystroke(.command, flags: flags))
        }
    }
}

// MARK: - Matchable

extension InputEvent: Matchable {
    func matches(_ rhs: InputEvent) -> Bool {
        switch (self, rhs) {
        case let (.key(dir1, ks1), .key(dir2, ks2)):
            return dir1 == dir2 && ks1.matches(ks2)
            
        case let (.flagsChanged(ks1), .flagsChanged(ks2)):
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
        case let .key(.down, keystroke):
            return ".key(.down,   \(keystrokePrintedParameters(keystroke)))"
            
        case let .key(.up, keystroke):
            return ".key(.up,     \(keystrokePrintedParameters(keystroke)))"
            
        case let .flagsChanged(keystroke):
            return ".flagsChanged(\(keystrokePrintedParameters(keystroke)))"
            
        case .mouseDown:
            return ".mouseDown"
        }
    }
    
    private func keystrokePrintedParameters(_ keystroke: Keystroke) -> String {
        var params = [keystroke.keyCode.description]
        if keystroke.flags != .maskNonCoalesced {
            params.append(keystroke.flags.description)
        }
        return params.joined(separator: ", ")
    }
}

// MARK: - CustomDebugStringConvertible

extension InputEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .key(direction, keystroke):
            return direction.debugDescription + keystroke.debugDescription
            
        case let .flagsChanged(keystroke):
            return keystroke.debugDescription
            
        case .mouseDown:
            return "🐁[↓]"
        }
    }
}

extension InputEvent.Direction: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch self {
        case .up: return ".up"
        case .down: return ".down"
        }
    }
    var debugDescription: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        }
    }
}
