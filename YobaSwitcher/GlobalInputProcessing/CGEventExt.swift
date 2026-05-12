//
//  CGEventExt.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

// sourcery: AutoMockable
protocol CoreGraphicsEvent {
    static func fromInputEvent(_ inputEvent: InputEvent) -> Self?
    
    func tapPostEvent(_ proxy: CGEventTapProxy?)
}

extension CGEvent {
    static func fromInputEvent(_ inputEvent: InputEvent) -> CGEvent? {
        switch inputEvent {
        case let .keyDown(keystroke):
            return fromKeystrokeDown(keystroke)
            
        case let .keyUp(keystroke):
            return fromKeystrokeUp(keystroke)
            
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

// MARK: - Matchable

extension CGEventFlags: Matchable {
    func matches(_ rhs: CGEventFlags) -> Bool {
        guard contains(.maskAlphaShift) == rhs.contains(.maskAlphaShift),
              contains(.maskShift) == rhs.contains(.maskShift),
              contains(.maskControl) == rhs.contains(.maskControl),
              contains(.maskAlternate) == rhs.contains(.maskAlternate),
              contains(.maskCommand) == rhs.contains(.maskCommand),
              contains(.maskHelp) == rhs.contains(.maskHelp),
              contains(.maskSecondaryFn) == rhs.contains(.maskSecondaryFn),
              contains(.maskNumericPad) == rhs.contains(.maskNumericPad)
        else { return false }
        // maskNonCoalesced is ignored intentionally
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
