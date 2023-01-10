//
//  CGEventExt.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

extension CGEvent {
    static func keyUp(_ keyCode: CGKeyCode) -> CGEvent? {
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
    }
    
    static func keyDown(_ keyCode: CGKeyCode) -> CGEvent? {
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
    }
}

extension CGEventFlags: CustomDebugStringConvertible {
    public var debugDescription: String {
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
        if contains(.maskNonCoalesced) {
            result.append("maskNonCoalesced")
        }
        return result.joined(separator: ", ")
    }
}

struct CGEventMaskSet: OptionSet {
    let rawValue: CGEventMask

    static let leftMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.leftMouseDown.rawValue))
    static let rightMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.rightMouseDown.rawValue))
    static let keyDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.keyDown.rawValue))
    static let keyUp = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.keyUp.rawValue))
    static let flagsChanged = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.flagsChanged.rawValue))
    static let otherMouseDown = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.otherMouseDown.rawValue))
    static let tapDisabledByTimeout = CGEventMaskSet(rawValue: UInt64(1 << CGEventType.tapDisabledByTimeout.rawValue))
}
