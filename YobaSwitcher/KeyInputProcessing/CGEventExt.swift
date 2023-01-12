//
//  CGEventExt.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//

import CoreGraphics

extension CGEventFlags: CustomStringConvertible {
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
        if contains(.maskNonCoalesced) {
            result.append("maskNonCoalesced")
        }
        let joined = result.map { ".\($0)" }.joined(separator: ", ")
        if result.count == 1 {
            return joined
        }
        return "[\(joined)]"
    }
}

extension CGEventFlags: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result: [String] = []
        if contains(.maskAlphaShift) {
            result.append("⇪")
        }
        if contains(.maskShift) {
            result.append("⇧")
        }
        if contains(.maskControl) {
            result.append("Ctrl")
        }
        if contains(.maskAlternate) {
            result.append("Alt")
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
        if contains(.maskNonCoalesced) {
            result.append("nc")
        }
        let joined = result.joined(separator: ",")
        if result.count == 1 {
            return joined
        }
        return "[\(joined)]"
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
}
