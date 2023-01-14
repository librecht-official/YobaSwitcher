//
//  Keystroke.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 14.01.2023.
//

import Carbon
import CoreGraphics

struct Keystroke: Equatable {
    let keyCode: KeyCode
    let flags: CGEventFlags
    let isAutorepeat: Bool
    
    init(_ keyCode: KeyCode, flags: CGEventFlags = .maskNonCoalesced, isAutorepeat: Bool = false) {
        self.keyCode = keyCode
        self.flags = flags
        self.isAutorepeat = isAutorepeat
    }
    
    init(keyCode: Int, flags: CGEventFlags = .maskNonCoalesced, isAutorepeat: Bool = false) {
        self.keyCode = KeyCode(keyCode)
        self.flags = flags
        self.isAutorepeat = isAutorepeat
    }
    
    init(event: CGEvent) {
        self.keyCode = KeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        self.flags = event.flags
        self.isAutorepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
    }
}

// MARK: - Matchable

extension Keystroke: Matchable {
    func matches(_ rhs: Keystroke) -> Bool {
        guard keyCode.matches(rhs.keyCode),
              flags.matches(rhs.flags),
              isAutorepeat == rhs.isAutorepeat
        else { return false }
        
        return true
    }
}

// MARK: - CustomStringConvertible

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

// MARK: -

struct KeyCode: Equatable, RawRepresentable {
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(_ value: Int) {
        self.init(rawValue: value)
    }
    
    init(_ value: Int64) {
        self.init(rawValue: Int(value))
    }
    
    var cgKeyCode: CGKeyCode {
        CGKeyCode(rawValue)
    }
    
    var isDelete: Bool {
        return rawValue == kVK_Delete || rawValue == kVK_ForwardDelete
    }
    
    static let option = KeyCode(kVK_Option)
    static let delete = KeyCode(kVK_Delete)
    static let shift = KeyCode(kVK_Shift)
    static let Z = KeyCode(kVK_ANSI_Z)
}

// MARK: - Matchable

extension KeyCode: Matchable {
    func matches(_ rhs: KeyCode) -> Bool {
        if self.rawValue == kVK_Option || self.rawValue == kVK_RightOption {
            guard rhs.rawValue == kVK_Option || rhs.rawValue == kVK_RightOption else {
                return false
            }
        } else {
            guard self.rawValue == rhs.rawValue else { return false }
        }
        return true
    }
}

// MARK: - CustomStringConvertible

extension KeyCode: CustomStringConvertible {
    var description: String { rawValue.description }
}

// MARK: - CustomDebugStringConvertible

extension KeyCode: CustomDebugStringConvertible {
    var debugDescription: String {
        keyCodesToString[rawValue] ?? String(rawValue)
    }
}

private let keyCodesToString: [Int: String] = [
    // Supplement as necessary
    kVK_ANSI_D: "D",
    kVK_ANSI_E: "E",
    kVK_ANSI_H: "H",
    kVK_ANSI_L: "L",
    kVK_ANSI_O: "O",
    kVK_ANSI_R: "R",
    kVK_ANSI_W: "W",    
    
    kVK_Space: "␣",
    kVK_Command: "⌘",
    kVK_RightCommand: "R⌘",
    kVK_Control: "⌃",
    kVK_RightControl: "R⌃",
    kVK_Option: "⌥",
    kVK_RightOption: "R⌥",
    kVK_Shift: "⇧",
    kVK_RightShift: "R⇧",
    kVK_Delete: "⌫",
    kVK_ForwardDelete: "F⌫",
]
