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
        didSet { Log.trace(characterKeystrokes) }
    }
    private(set) var latestInputEvents = DisplacingBuffer<InputEvent>(maxSize: 3) {
        didSet { Log.trace(latestInputEvents) }
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
        updateCharacterKeystrokes(withNew: keystroke)
        
        if latestInputEvents.last.matches(Patterns.ctrlOptZ) {
            Log.info("Hit Ctrl+Opt+Z")
            changeSelectedTextCase()
            return nil
        }
        
        return event
    }
    
    @discardableResult
    func handleKeyUp(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.keyUp(keystroke))
        
        return event
    }
    
    @discardableResult
    func handleFlagsChange(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.flagsChanged(keystroke))
        
        let last2 = latestInputEvents.takeLast(2)
        if last2.matches(Patterns.optionDownAndUp) {
            Log.info("Hit Option")
            if selectedTextManager.replaceSelectedTextWithAlternativeKeyboardLanguage() {
                return nil
            }
            return retypeCharacterKeystrokes(event, proxy)
        }
        
        return event
    }
    
    @discardableResult
    func handleMouseDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        latestInputEvents.append(.mouseDown)
        characterKeystrokes = []
        
        return event
    }
    
    // MARK: Helpers
    
    private enum Patterns {
        static let optionDownAndUp: [InputEvent] = [
            .flagsChanged(Keystroke(.option, flags: .maskAlternate)),
            .flagsChanged(Keystroke(.option))
        ]
        static let ctrlOptZ: InputEvent =
            .keyDown(Keystroke(.Z, flags: [.maskControl, .maskAlternate]))
    }
    
    private func isItCharacterProducingKey(_ keyCode: KeyCode) -> Bool {
        kVK_ANSI_A <= keyCode.rawValue && keyCode.rawValue <= kVK_ANSI_Grave
    }
    
    private func isItPossibleShortCut(_ keystroke: Keystroke) -> Bool {
        return keystroke.flags.contains(.maskAlternate)
        || keystroke.flags.contains(.maskCommand)
        || keystroke.flags.contains(.maskControl)
        || keystroke.flags.contains(.maskSecondaryFn)
    }
    
    private func updateCharacterKeystrokes(withNew keystroke: Keystroke) {
        if keystroke.keyCode.isDelete {
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
    
    private func retypeCharacterKeystrokes(_ event: CGEvent, _ proxy: CGEventTapProxy) -> CGEvent? {
        if characterKeystrokes.isEmpty { return event }
        
        Log.info("Retype character keystrokes: \(characterKeystrokes)")
        
        for _ in characterKeystrokes {
            keyboard.postInputEvent(.keyDown(Keystroke(.delete)), proxy)
            keyboard.postInputEvent(.keyUp(Keystroke(.delete)), proxy)
        }
        
        keyboard.switchInputSource { [weak self] in
            self?.typeCharacterKeystrokes(proxy)
        }
        
        return nil
    }
    
    private func typeCharacterKeystrokes(_ proxy: CGEventTapProxy) {
        for keystroke in characterKeystrokes {
            if keystroke.flags.contains(.maskShift) {
                let shift = InputEvent.flagsChanged(
                    Keystroke(.shift, flags: [.maskShift, .maskNonCoalesced]),
                    keyDown: true
                )
                keyboard.postInputEvent(shift, proxy)
            }
            
            keyboard.postInputEvent(.keyDown(keystroke), proxy)
            keyboard.postInputEvent(.keyUp(keystroke), proxy)
            
            if keystroke.flags.contains(.maskShift) {
                let shift = InputEvent.flagsChanged(
                    Keystroke(.shift, flags: [.maskNonCoalesced]),
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
