//
//  GlobalInputProcessingController.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Carbon
import CoreGraphics

final class GlobalInputProcessingController: GlobalInputMonitorHandler {
    let selectedTextManager: SelectedTextManager
    let keyboard: VirtualKeyboardProtocol
    let systemWide: SystemWideAccessibility
    // Contains "currently" pressed keys that will be retyped with another input source when the user taps Option key
    private(set) var keysBuffer: [Keystroke] = [] {
        didSet { Log.info("keysBuffer:", keysBuffer) }
    }
    // A flag to track if Option key was pressed (down) with no other keys
    private(set) var optionKeyIsDownExclusively: Bool = false {
        didSet { Log.info("optionKeyIsDownExclusively: \(optionKeyIsDownExclusively)") }
    }
    
    init(selectedTextManager: SelectedTextManager, keyboard: VirtualKeyboardProtocol, systemWide: SystemWideAccessibility) {
        self.selectedTextManager = selectedTextManager
        self.keyboard = keyboard
        self.systemWide = systemWide
    }

    // MARK: GlobalInputMonitorHandler
    
    @discardableResult
    func handleKeyDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        optionKeyIsDownExclusively = false
        
        if keystroke.keyCode == kVK_ANSI_Z && event.flags.contains([.maskControl, .maskAlternate]) {
            changeSelectedTextCase()
            return nil
        }
        
        modifyKeyBuffer(with: keystroke)
        
        return event
    }
    
    private func modifyKeyBuffer(with keystroke: Keystroke) {
        if keystroke.keyCode == kVK_Delete || keystroke.keyCode == kVK_ForwardDelete {
            if !keysBuffer.isEmpty {
                keysBuffer.removeLast()
            }
            return
        }
        
        if !isItCharacterProducingKey(keystroke.keyCode) || isItPossibleShortCut(keystroke) {
            keysBuffer = []
            return
        }
        
        if !keystroke.isAutorepeat {
            keysBuffer.append(keystroke)
        }
    }
    
    @discardableResult
    func handleKeyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        return event
    }
    
    @discardableResult
    func handleFlagsChange(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        if isItOptionKeyDownExclusively(event) {
            optionKeyIsDownExclusively = true
        }
        if isItOptionKeyUp(event) && optionKeyIsDownExclusively {
            Log.info("Option key is up")
            optionKeyIsDownExclusively = false
            
            if selectedTextManager.replaceSelectedTextWithAlternativeKeyboardLanguage() {
                return nil
            }
            return retypeKeyBuffer(event, proxy)
        }
        
        return event
    }
    
    @discardableResult
    func handleMouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        optionKeyIsDownExclusively = false
        keysBuffer = []
        
        return event
    }
    
    // MARK: Helpers
    
    private func isItCharacterProducingKey(_ keyCode: Int) -> Bool {
        kVK_ANSI_A <= keyCode && keyCode <= kVK_ANSI_Grave
    }
    
    private func isItPossibleShortCut(_ keystroke: Keystroke) -> Bool {
        return keystroke.flags.contains(.maskAlternate)
        || keystroke.flags.contains(.maskCommand)
        || keystroke.flags.contains(.maskControl)
        || keystroke.flags.contains(.maskSecondaryFn)
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
        
        Log.info("Retype keys buffer: \(keysBuffer)")
        
        for _ in keysBuffer {
            keyboard.postKeystrokeEvent(.keyDown(Keystroke(keyCode: kVK_Delete)), proxy)
            keyboard.postKeystrokeEvent(.keyUp(Keystroke(keyCode: kVK_Delete)), proxy)
        }
        
        keyboard.switchInputSource { [weak self] in
            self?.typeKeyBuffer(proxy)
        }
        
        return nil
    }
    
    private func typeKeyBuffer(_ proxy: CGEventTapProxy) {
        for keystroke in keysBuffer {
            if keystroke.flags.contains(.maskShift) {
                let shift = KeystrokeEvent.flagsChanged(
                    Keystroke(keyCode: kVK_Shift, flags: [.maskShift, .maskNonCoalesced]),
                    keyDown: true
                )
                keyboard.postKeystrokeEvent(shift, proxy)
            }
            
            keyboard.postKeystrokeEvent(.keyDown(keystroke), proxy)
            keyboard.postKeystrokeEvent(.keyUp(keystroke), proxy)
            
            if keystroke.flags.contains(.maskShift) {
                let shift = KeystrokeEvent.flagsChanged(
                    Keystroke(keyCode: kVK_Shift, flags: [.maskNonCoalesced]),
                    keyDown: false
                )
                keyboard.postKeystrokeEvent(shift, proxy)
            }
        }
    }
    
    private func changeSelectedTextCase() {
        guard let focusedElement = systemWide.focusedElement() else { return }
        let selectedText = focusedElement.selectedText
        
        if selectedText.isEmpty {
            Log.info("Selected text is empty")
            return
        }
        let uppercasedText = selectedText.uppercased()
        if selectedText == uppercasedText {
            focusedElement.selectedText = selectedText.lowercased()
        } else {
            focusedElement.selectedText = uppercasedText
        }
    }
}