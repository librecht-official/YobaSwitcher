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
    
    init(_ keyCode: KeyCode, flags: CGEventFlags = [], autorepeat: Bool = false) {
        self.keyCode = keyCode
        self.flags = flags.union(.maskNonCoalesced)
        self.isAutorepeat = autorepeat
    }
    
    init(keyCode: Int, flags: CGEventFlags = [], autorepeat: Bool = false) {
        self.keyCode = KeyCode(keyCode)
        self.flags = flags.union(.maskNonCoalesced)
        self.isAutorepeat = autorepeat
    }
    
    init<Event: HIDEvent>(event: Event) {
        self.keyCode = KeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        self.flags = event.flags
        self.isAutorepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
    }
    
    var isItPresumablyShortCut: Bool {
        return flags.contains(.maskAlternate)
        || flags.contains(.maskCommand)
        || flags.contains(.maskControl)
        || flags.contains(.maskSecondaryFn)
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

extension Keystroke: CustomStringConvertible, CustomDebugStringConvertible {
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
    
    var debugDescription: String {
        var mods = flags.stringValues
        if isAutorepeat {
            mods.append("AR")
        }
        var result = keyCode.debugDescription
        if !mods.isEmpty {
            result.append("(\(mods.joined(separator: ",")))")
        }
        return result
    }
}

// MARK: - KeyCode

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
    
    var isCharacterProducingKey: Bool {
        kVK_ANSI_A <= rawValue && rawValue <= kVK_ANSI_Grave
    }
    
    static let option = KeyCode(kVK_Option)
    static let command = KeyCode(kVK_Command)
    static let shift = KeyCode(kVK_Shift)
    static let delete = KeyCode(kVK_Delete)
    static let c = KeyCode(kVK_ANSI_C)
    static let v = KeyCode(kVK_ANSI_V)
    static let z = KeyCode(kVK_ANSI_Z)
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

extension KeyCode: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        KeyCode.keyCodeNames[rawValue] ?? rawValue.description
    }
    
    var debugDescription: String {
        "\(rawValue) \'\(KeyCode.keyCodesShortNames[rawValue] ?? String(rawValue))\'"
    }
    
    static let keyCodeNames: [Int: String] = [
        kVK_ANSI_A: "kVK_ANSI_A",
        kVK_ANSI_S: "kVK_ANSI_S",
        kVK_ANSI_D: "kVK_ANSI_D",
        kVK_ANSI_F: "kVK_ANSI_F",
        kVK_ANSI_H: "kVK_ANSI_H",
        kVK_ANSI_G: "kVK_ANSI_G",
        kVK_ANSI_Z: "kVK_ANSI_Z",
        kVK_ANSI_X: "kVK_ANSI_X",
        kVK_ANSI_C: "kVK_ANSI_C",
        kVK_ANSI_V: "kVK_ANSI_V",
        kVK_ANSI_B: "kVK_ANSI_B",
        kVK_ANSI_Q: "kVK_ANSI_Q",
        kVK_ANSI_W: "kVK_ANSI_W",
        kVK_ANSI_E: "kVK_ANSI_E",
        kVK_ANSI_R: "kVK_ANSI_R",
        kVK_ANSI_Y: "kVK_ANSI_Y",
        kVK_ANSI_T: "kVK_ANSI_T",
        kVK_ANSI_1: "kVK_ANSI_1",
        kVK_ANSI_2: "kVK_ANSI_2",
        kVK_ANSI_3: "kVK_ANSI_3",
        kVK_ANSI_4: "kVK_ANSI_4",
        kVK_ANSI_6: "kVK_ANSI_6",
        kVK_ANSI_5: "kVK_ANSI_5",
        kVK_ANSI_Equal: "kVK_ANSI_Equal",
        kVK_ANSI_9: "kVK_ANSI_9",
        kVK_ANSI_7: "kVK_ANSI_7",
        kVK_ANSI_Minus: "kVK_ANSI_Minus",
        kVK_ANSI_8: "kVK_ANSI_8",
        kVK_ANSI_0: "kVK_ANSI_0",
        kVK_ANSI_RightBracket: "kVK_ANSI_RightBracket",
        kVK_ANSI_O: "kVK_ANSI_O",
        kVK_ANSI_U: "kVK_ANSI_U",
        kVK_ANSI_LeftBracket: "kVK_ANSI_LeftBracket",
        kVK_ANSI_I: "kVK_ANSI_I",
        kVK_ANSI_P: "kVK_ANSI_P",
        kVK_ANSI_L: "kVK_ANSI_L",
        kVK_ANSI_J: "kVK_ANSI_J",
        kVK_ANSI_Quote: "kVK_ANSI_Quote",
        kVK_ANSI_K: "kVK_ANSI_K",
        kVK_ANSI_Semicolon: "kVK_ANSI_Semicolon",
        kVK_ANSI_Backslash: "kVK_ANSI_Backslash",
        kVK_ANSI_Comma: "kVK_ANSI_Comma",
        kVK_ANSI_Slash: "kVK_ANSI_Slash",
        kVK_ANSI_N: "kVK_ANSI_N",
        kVK_ANSI_M: "kVK_ANSI_M",
        kVK_ANSI_Period: "kVK_ANSI_Period",
        kVK_ANSI_Grave: "kVK_ANSI_Grave",
        kVK_ANSI_KeypadDecimal: "kVK_ANSI_KeypadDecimal",
        kVK_ANSI_KeypadMultiply: "kVK_ANSI_KeypadMultiply",
        kVK_ANSI_KeypadPlus: "kVK_ANSI_KeypadPlus",
        kVK_ANSI_KeypadClear: "kVK_ANSI_KeypadClear",
        kVK_ANSI_KeypadDivide: "kVK_ANSI_KeypadDivide",
        kVK_ANSI_KeypadEnter: "kVK_ANSI_KeypadEnter",
        kVK_ANSI_KeypadMinus: "kVK_ANSI_KeypadMinus",
        kVK_ANSI_KeypadEquals: "kVK_ANSI_KeypadEquals",
        kVK_ANSI_Keypad0: "kVK_ANSI_Keypad0",
        kVK_ANSI_Keypad1: "kVK_ANSI_Keypad1",
        kVK_ANSI_Keypad2: "kVK_ANSI_Keypad2",
        kVK_ANSI_Keypad3: "kVK_ANSI_Keypad3",
        kVK_ANSI_Keypad4: "kVK_ANSI_Keypad4",
        kVK_ANSI_Keypad5: "kVK_ANSI_Keypad5",
        kVK_ANSI_Keypad6: "kVK_ANSI_Keypad6",
        kVK_ANSI_Keypad7: "kVK_ANSI_Keypad7",
        kVK_ANSI_Keypad8: "kVK_ANSI_Keypad8",
        kVK_ANSI_Keypad9: "kVK_ANSI_Keypad9",

        kVK_Return: "kVK_Return",
        kVK_Tab: "kVK_Tab",
        kVK_Space: "kVK_Space",
        kVK_Delete: "kVK_Delete",
        kVK_Escape: "kVK_Escape",
        kVK_Command: "kVK_Command",
        kVK_RightCommand: "kVK_RightCommand",
        kVK_Shift: "kVK_Shift",
        kVK_CapsLock: "kVK_CapsLock",
        kVK_Option: "kVK_Option",
        kVK_Control: "kVK_Control",
        kVK_RightShift: "kVK_RightShift",
        kVK_RightOption: "kVK_RightOption",
        kVK_RightControl: "kVK_RightControl",
        kVK_Function: "kVK_Function",
        kVK_F17: "kVK_F17",
        kVK_VolumeUp: "kVK_VolumeUp",
        kVK_VolumeDown: "kVK_VolumeDown",
        kVK_Mute: "kVK_Mute",
        kVK_F18: "kVK_F18",
        kVK_F19: "kVK_F19",
        kVK_F20: "kVK_F20",
        kVK_F5: "kVK_F5",
        kVK_F6: "kVK_F6",
        kVK_F7: "kVK_F7",
        kVK_F3: "kVK_F3",
        kVK_F8: "kVK_F8",
        kVK_F9: "kVK_F9",
        kVK_F11: "kVK_F11",
        kVK_F13: "kVK_F13",
        kVK_F16: "kVK_F16",
        kVK_F14: "kVK_F14",
        kVK_F10: "kVK_F10",
        kVK_F12: "kVK_F12",
        kVK_F15: "kVK_F15",
        kVK_Help: "kVK_Help",
        kVK_Home: "kVK_Home",
        kVK_PageUp: "kVK_PageUp",
        kVK_ForwardDelete: "kVK_ForwardDelete",
        kVK_F4: "kVK_F4",
        kVK_End: "kVK_End",
        kVK_F2: "kVK_F2",
        kVK_PageDown: "kVK_PageDown",
        kVK_F1: "kVK_F1",
        kVK_LeftArrow: "kVK_LeftArrow",
        kVK_RightArrow: "kVK_RightArrow",
        kVK_DownArrow: "kVK_DownArrow",
        kVK_UpArrow: "kVK_UpArrow",
        kVK_ISO_Section: "kVK_ISO_Section",
    ]
    
    static let keyCodesShortNames: [Int: String] = [
        // Supplement as necessary
        kVK_ANSI_Q: "Q",
        kVK_ANSI_W: "W",
        kVK_ANSI_E: "E",
        kVK_ANSI_R: "R",
        kVK_ANSI_T: "T",
        kVK_ANSI_Y: "Y",
        kVK_ANSI_U: "U",
        kVK_ANSI_I: "I",
        kVK_ANSI_O: "O",
        kVK_ANSI_P: "P",
        kVK_ANSI_A: "A",
        kVK_ANSI_S: "S",
        kVK_ANSI_D: "D",
        kVK_ANSI_F: "F",
        kVK_ANSI_G: "G",
        kVK_ANSI_H: "H",
        kVK_ANSI_J: "J",
        kVK_ANSI_K: "K",
        kVK_ANSI_L: "L",
        kVK_ANSI_Z: "Z",
        kVK_ANSI_X: "X",
        kVK_ANSI_C: "C",
        kVK_ANSI_V: "V",
        kVK_ANSI_B: "B",
        kVK_ANSI_N: "N",
        kVK_ANSI_M: "M",
        
        kVK_Space: "␣",
        kVK_Return: "↵",
        kVK_Delete: "⌫",
        kVK_ForwardDelete: "F⌫",
        kVK_Tab: "⇥",
        kVK_ANSI_LeftBracket: "[",
        kVK_ANSI_RightBracket: "]",
        kVK_ANSI_Semicolon: ";",
        kVK_ANSI_Quote: "'",
        kVK_ANSI_Backslash: "\\",
        kVK_ANSI_Comma: ",",
        kVK_ANSI_Period: ".",
        kVK_ANSI_Slash: "/",
        kVK_ANSI_Grave: "~",
        kVK_ISO_Section: "§",
        
        // MARK: Non-character producing
        
        kVK_UpArrow: "↑",
        kVK_DownArrow: "↓",
        kVK_LeftArrow: "←",
        kVK_RightArrow: "→",
        
        kVK_Command: "Cmd",
        kVK_RightCommand: "R Cmd",
        kVK_Control: "Ctrl",
        kVK_RightControl: "R Ctrl",
        kVK_Option: "Opt",
        kVK_RightOption: "R Opt",
        kVK_Shift: "Shift",
        kVK_RightShift: "R Shift",
        kVK_CapsLock: "Capslock",
        kVK_Function: "fn"
    ]
}
