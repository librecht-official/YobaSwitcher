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
    private(set) var characterKeystrokes: [Keystroke] = [] {
        didSet { Log.info("keysBuffer:", characterKeystrokes) }
    }
    private(set) var latestInputEvents = DisplacingBuffer<InputEvent>(maxSize: 3) {
        didSet { Log.debug("latestInputEvents:", latestInputEvents) }
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
        latestInputEvents.append(.keyDown(keystroke))
        modifyKeyBuffer(with: keystroke)
        
        return handleLatestInputEvents(event, proxy)
    }
    
    private func modifyKeyBuffer(with keystroke: Keystroke) {
        if keystroke.keyCode == kVK_Delete || keystroke.keyCode == kVK_ForwardDelete {
            if !characterKeystrokes.isEmpty {
                characterKeystrokes.removeLast()
            }
            return
        }
        
        if !isItCharacterProducingKey(keystroke.keyCode) || isItPossibleShortCut(keystroke) {
            characterKeystrokes = []
            return
        }
        
        if !keystroke.isAutorepeat {
            characterKeystrokes.append(keystroke)
        }
    }
    
    @discardableResult
    func handleKeyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.keyUp(keystroke))
        
        return handleLatestInputEvents(event, proxy)
    }
    
    @discardableResult
    func handleFlagsChange(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.flagsChanged(keystroke))
        
        return handleLatestInputEvents(event, proxy)
    }
    
    @discardableResult
    func handleMouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        latestInputEvents.append(.mouseDown)
        characterKeystrokes = []
        
        return handleLatestInputEvents(event, proxy)
    }
    
    // MARK: Helpers
    
    private enum Patterns {
        static let optionDownAndUp: [InputEvent] = [
            .flagsChanged(Keystroke(keyCode: kVK_Option, flags: .maskAlternate)),
            .flagsChanged(Keystroke(keyCode: kVK_Option))
        ]
        static let ctrlOptZ: InputEvent =
            .keyDown(Keystroke(keyCode: kVK_ANSI_Z, flags: [.maskControl, .maskAlternate]))
    }
    
    private func handleLatestInputEvents(_ event: CGEvent, _ proxy: CGEventTapProxy) -> CGEvent? {
        let last2 = latestInputEvents.takeLast(2)
        
        if last2.matches(Patterns.optionDownAndUp) {
            Log.info("Option key is hit")
            if selectedTextManager.replaceSelectedTextWithAlternativeKeyboardLanguage() {
                return nil
            }
            return retypeKeyBuffer(event, proxy)
        }
        if latestInputEvents.last.matches(Patterns.ctrlOptZ) {
            Log.info("Ctrl+Opt+Z")
            changeSelectedTextCase()
            return nil
        }
        
        return event
    }
    
    private func isItCharacterProducingKey(_ keyCode: Int) -> Bool {
        kVK_ANSI_A <= keyCode && keyCode <= kVK_ANSI_Grave
    }
    
    private func isItPossibleShortCut(_ keystroke: Keystroke) -> Bool {
        return keystroke.flags.contains(.maskAlternate)
        || keystroke.flags.contains(.maskCommand)
        || keystroke.flags.contains(.maskControl)
        || keystroke.flags.contains(.maskSecondaryFn)
    }
    
    private func retypeKeyBuffer(_ event: CGEvent, _ proxy: CGEventTapProxy) -> CGEvent? {
        if characterKeystrokes.isEmpty { return event }
        
        Log.info("Retype keys buffer: \(characterKeystrokes)")
        
        for _ in characterKeystrokes {
            keyboard.postInputEvent(.keyDown(Keystroke(keyCode: kVK_Delete)), proxy)
            keyboard.postInputEvent(.keyUp(Keystroke(keyCode: kVK_Delete)), proxy)
        }
        
        keyboard.switchInputSource { [weak self] in
            self?.typeKeyBuffer(proxy)
        }
        
        return nil
    }
    
    private func typeKeyBuffer(_ proxy: CGEventTapProxy) {
        for keystroke in characterKeystrokes {
            if keystroke.flags.contains(.maskShift) {
                let shift = InputEvent.flagsChanged(
                    Keystroke(keyCode: kVK_Shift, flags: [.maskShift, .maskNonCoalesced]),
                    keyDown: true
                )
                keyboard.postInputEvent(shift, proxy)
            }
            
            keyboard.postInputEvent(.keyDown(keystroke), proxy)
            keyboard.postInputEvent(.keyUp(keystroke), proxy)
            
            if keystroke.flags.contains(.maskShift) {
                let shift = InputEvent.flagsChanged(
                    Keystroke(keyCode: kVK_Shift, flags: [.maskNonCoalesced]),
                    keyDown: false
                )
                keyboard.postInputEvent(shift, proxy)
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
