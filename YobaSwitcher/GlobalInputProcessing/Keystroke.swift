//
//  Keystroke.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 14.01.2023.
//

import Carbon
import CoreGraphics

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

extension Keystroke: Matchable {
    func matches(_ rhs: Keystroke) -> Bool {
        if self.keyCode == kVK_Option || self.keyCode == kVK_RightOption {
            guard rhs.keyCode == kVK_Option || rhs.keyCode == kVK_RightOption else {
                return false
            }
        } else {
            guard self.keyCode == rhs.keyCode else { return false }
        }
        
        guard self.flags.matches(rhs.flags) else { return false }
        
        guard self.isAutorepeat == rhs.isAutorepeat else { return false }
        
        return true
    }
}

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
