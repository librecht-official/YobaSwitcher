//
//  KeyInputController.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Carbon
import CoreGraphics

final class KeyInputController: GlobalInputMonitorDelegate {
    // Contains "currently" pressed keys that will be retyped with another input source when the user taps "option" key
    private(set) var keysBuffer: [Int64] = [] {
        didSet { print("keysBuffer: \(keysBuffer)") }
    }
    // A flag to track if "Option" key is tapped (down) with no other keys
    private(set) var optionKeyIsDownExclusively: Bool = false {
        didSet { print("optionKeyIsDownExclusively: \(optionKeyIsDownExclusively)") }
    }

    // MARK: GlobalInputMonitorDelegate
    
    func keyDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        optionKeyIsDownExclusively = false
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if keyCode == kVK_ANSI_Z && event.flags.contains([.maskControl, .maskAlternate]) {
            print("ctrl+opt+Z")//⌃⌥Z
            replaceSelectedText()
            return nil
        }
        return event
    }
    
    func keyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        modifyKeyBuffer(with: event)
        return event
    }
    
    private func modifyKeyBuffer(with event: CGEvent) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if keyCode == kVK_Delete || keyCode == kVK_ForwardDelete {
            if !keysBuffer.isEmpty {
                keysBuffer.removeLast()
            }
            return
        }
        
        if !isItCharacterProducingKey(keyCode) || isItPossibleShortCut(event) {
            keysBuffer = []
            return
        }
        
        keysBuffer.append(keyCode)
    }
    
    func flagsChanged(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        if isItOptionKeyDownExclusively(event) {
            optionKeyIsDownExclusively = true
        }
        if isItOptionKeyUp(event) && optionKeyIsDownExclusively {
            print("Option key is up")
            optionKeyIsDownExclusively = false
            return retypeKeyBuffer(event, proxy)
        }
        
        return event
    }
    
    func mouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        optionKeyIsDownExclusively = false
        keysBuffer = []
        
        return event
    }
    
    // MARK: Helpers
    
    private func isItCharacterProducingKey(_ keyCode: Int64) -> Bool {
        kVK_ANSI_A <= keyCode && keyCode <= kVK_ANSI_Grave
    }
    
    private func isItPossibleShortCut(_ event: CGEvent) -> Bool {
        event.flags.contains(.maskAlternate)
        || event.flags.contains(.maskCommand)
        || event.flags.contains(.maskControl)
        || event.flags.contains(.maskSecondaryFn)
    }
    
    private func isItOptionKeyDownExclusively(_ event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        return (keyCode == kVK_Option || keyCode == kVK_RightOption)
            && event.flags.contains(.maskAlternate)
            && !event.flags.contains(.maskCommand)
            && !event.flags.contains(.maskControl)
            && !event.flags.contains(.maskShift)
            && !event.flags.contains(.maskHelp)
            && !event.flags.contains(.maskNumericPad)
            && !event.flags.contains(.maskSecondaryFn)
    }
    
    private func isItOptionKeyUp(_ event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        return (keyCode == kVK_Option || keyCode == kVK_RightOption) && !event.flags.contains(.maskAlternate)
    }
    
    private func retypeKeyBuffer(_ event: CGEvent, _ proxy: CGEventTapProxy) -> CGEvent? {
        if keysBuffer.isEmpty { return event }
        
        print("retype keys buffer: \(keysBuffer)")
        
        // Delay here because "option" key is still down until we return from the callback. If no delay - each "Delete" event will remove 1 word instead of 1 character.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [keysBuffer] in
            for _ in keysBuffer {
                CGEvent.keyDown(CGKeyCode(kVK_Delete))?.tapPostEvent(proxy)
                CGEvent.keyUp(CGKeyCode(kVK_Delete))?.tapPostEvent(proxy)
            }
                    
            self.switchInputSource()
            
            for key in keysBuffer {
                CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: true)?.tapPostEvent(proxy)
                CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: false)?.tapPostEvent(proxy)
            }
        }
        
        return event
    }
    
    func switchInputSource() {
        let inputSourceCriteria = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true
        ]  as CFDictionary
        let sourceList = InputSource.fetchList(filter: inputSourceCriteria)
        
        guard let nonSelectedSource = sourceList.first(where: { !$0.isSelected }) else {
            return
        }
        
        print(sourceList)
        
        TISSelectInputSource(nonSelectedSource.asTISInputSource)
    }
    
    func replaceSelectedText() {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedUIElementRef: CFTypeRef?
        let result1 = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedUIElementRef)
        guard let focusedUIElement = focusedUIElementRef, CFGetTypeID(focusedUIElement) == AXUIElementGetTypeID(), result1 == .success else {
            print("No focused element: \(result1)")
            return
        }
        
        var selectedTextRef: CFTypeRef?
        let result2 = AXUIElementCopyAttributeValue(focusedUIElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextRef)
        guard let selectedText = selectedTextRef as? String, result2 == .success else {
            print("No selected text: \(result2)")
            return
        }
        
        print("selectedText: \(selectedText)")
        
        if selectedText.isEmpty {
            print("selected text is empty")
            return
        }
        var isSettable = DarwinBoolean(false)
        let result3 = AXUIElementIsAttributeSettable(focusedUIElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &isSettable)
        print("isSettable: \(isSettable), result3: \(result3)")

        if isSettable.boolValue {
            let result4 = AXUIElementSetAttributeValue(focusedUIElement as! AXUIElement, kAXSelectedTextAttribute as CFString, selectedText.uppercased() as CFString)
            print("result4: \(result4)")
        }
    }
}
