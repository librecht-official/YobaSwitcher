//
//  CGEventExt.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics
import Carbon

/// Human Interface Device Event
protocol HIDEvent {
    var type: CGEventType { get }
    
    var flags: CGEventFlags { get }
    
    func getIntegerValueField(_ field: CGEventField) -> Int64
}

extension CGEvent: HIDEvent {
    static func fromInputEvent(_ inputEvent: InputEvent) -> CGEvent? {
        switch inputEvent {
        case let .key(direction, keystroke):
            let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keystroke.keyCode.cgKeyCode, keyDown: direction == .down)
            cgEvent?.flags = keystroke.flags
            return cgEvent
            
        case let .flagsChanged(keystroke):
            let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keystroke.keyCode.cgKeyCode, keyDown: false)
            cgEvent?.flags = keystroke.flags
            return cgEvent
            
        case .mouseDown:
            let cgEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)
            return cgEvent
        }
    }
}

// Used for recording events for tests
extension CGEvent: @retroactive CustomStringConvertible {
    public var description: String {
        switch type {
        case .flagsChanged:
            return "CGEvent.flagsChanged(\(printedParameters))"
            
        case .keyDown:
            return "CGEvent.key(.down,   \(printedParameters))"
            
        case .keyUp:
            return "CGEvent.key(.up,     \(printedParameters))"
        
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return "CGEvent.mouseDown"
            
        default:
            return "<CGEvent unknown>"
        }
    }
    
    private var printedParameters: String {
        var params = [keyCodeName]
        if flags != .maskNonCoalesced {
            params.append(flags.description)
        }
        return params.joined(separator: ", ")
    }
    
    private var keyCodeName: String {
        let keyCode = Int(getIntegerValueField(.keyboardEventKeycode))
        return KeyCode.keyCodeNames[keyCode] ?? keyCode.description
    }
}

// MARK: - Matchable

extension CGEventFlags: Matchable {
    func matches(_ rhs: CGEventFlags) -> Bool {
        guard contains(.maskShift) == rhs.contains(.maskShift),
              contains(.maskControl) == rhs.contains(.maskControl),
              contains(.maskAlternate) == rhs.contains(.maskAlternate),
              contains(.maskCommand) == rhs.contains(.maskCommand),
              contains(.maskHelp) == rhs.contains(.maskHelp),
              contains(.maskSecondaryFn) == rhs.contains(.maskSecondaryFn),
              contains(.maskNumericPad) == rhs.contains(.maskNumericPad)
        else { return false }
        // maskAlphaShift and maskNonCoalesced are ignored intentionally
        return true
    }
}

// MARK: - CustomStringConvertible

extension CGEventFlags: @retroactive CustomStringConvertible {
    public var description: String {
        var result: [String] = []
        if contains(.maskAlphaShift) {
            result.append("maskAlphaShift")
        }
        if contains(.maskShift) {
            result.append("maskShift")
        }
        if contains(.maskControl) {
            result.append("maskControl")
        }
        if contains(.maskAlternate) {
            result.append("maskAlternate")
        }
        if contains(.maskCommand) {
            result.append("maskCommand")
        }
        if contains(.maskHelp) {
            result.append("maskHelp")
        }
        if contains(.maskSecondaryFn) {
            result.append("maskSecondaryFn")
        }
        if contains(.maskNumericPad) {
            result.append("maskNumericPad")
        }
//        if contains(.maskNonCoalesced) {
//            result.append("maskNonCoalesced")
//        }
        let joined = result.map { ".\($0)" }.joined(separator: ", ")
        if result.count == 1 {
            return joined
        }
        return "[\(joined)]"
    }
    
    public var stringValues: [String] {
        var result: [String] = []
        if contains(.maskAlphaShift) {
            result.append("⇪")
        }
        if contains(.maskShift) {
            result.append("⇧")
        }
        if contains(.maskControl) {
            result.append("^")
        }
        if contains(.maskAlternate) {
            result.append("⌥")
        }
        if contains(.maskCommand) {
            result.append("⌘")
        }
        if contains(.maskHelp) {
            result.append("Help")
        }
        if contains(.maskSecondaryFn) {
            result.append("Fn")
        }
        if contains(.maskNumericPad) {
            result.append("NumPad")
        }
        return result
    }
}

// MARK: -

struct CGEventMaskSet: OptionSet {
    let rawValue: CGEventMask

    static let leftMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.leftMouseDown.rawValue))
    static let rightMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.rightMouseDown.rawValue))
    static let keyDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.keyDown.rawValue))
    static let keyUp = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.keyUp.rawValue))
    static let flagsChanged = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.flagsChanged.rawValue))
    static let otherMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.otherMouseDown.rawValue))
}
