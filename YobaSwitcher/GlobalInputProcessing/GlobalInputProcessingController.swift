//
//  GlobalInputProcessingController.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Carbon
import CoreGraphics

// TODO: Rename GlobalInputProcessor
final class GlobalInputProcessingController: GlobalInputHandler {
    let selectedTextManager: SelectedTextManager
    let inputSourceManager: TextInputSourceManager
    let systemEvents = StaticDependency.systemEvents
    
    // Contains "currently" pressed keys that will be retyped with another input source when the user taps Option key
    private(set) var characterKeystrokes: [Keystroke] = []
    private(set) var latestInputEvents = DisplacingBuffer<InputEvent>(maxSize: 3)
    
    init(selectedTextManager: SelectedTextManager, inputSourceManager: TextInputSourceManager) {
        self.selectedTextManager = selectedTextManager
        self.inputSourceManager = inputSourceManager
    }

    // MARK: GlobalInputHandler
    
    @discardableResult
    func handleKeyDown(event: CGEvent, proxy: CGEventTapProxy) -> CGEvent? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.keyDown(keystroke))
        updateCharacterKeystrokes(withNew: keystroke)
        
        if latestInputEvents.last.matches(Patterns.ctrlOptZ) {
            Log.inputProcessing.info("Hit Ctrl+Opt+Z")
            selectedTextManager.changeSelectedTextCase()
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
        
        let last2 = latestInputEvents.suffix(2)
        
        if last2.matches(Patterns.optionPress) || last2.matches(Patterns.optionPressWithCapslock) {
            Log.inputProcessing.info("Hit Option")
            if characterKeystrokes.isEmpty {
                selectedTextManager.replaceSelectedTextWithAlternativeKeyboardLayout()
            } else {
                retypeCharacterKeystrokes(event, proxy)
            }
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
        static let optionPress: [InputEvent] = [
            .flagsChanged(Keystroke(.option, flags: .maskAlternate)),
            .flagsChanged(Keystroke(.option))
        ]
        static let optionPressWithCapslock: [InputEvent] = [
            .flagsChanged(Keystroke(.option, flags: [.maskAlternate, .maskAlphaShift])),
            .flagsChanged(Keystroke(.option, flags: .maskAlphaShift))
        ]
        static let ctrlOptZ: InputEvent =
            .keyDown(Keystroke(.z, flags: [.maskControl, .maskAlternate]))
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
    
    private func retypeCharacterKeystrokes(_ event: CGEvent, _ proxy: CGEventTapProxy) {
        if characterKeystrokes.isEmpty { return }
        
        Log.inputProcessing.debug("Retype character keystrokes: \(self.characterKeystrokes)")
        
        inputSourceManager.switchInputSource { [weak self] in
            self?.eraseAndTypeKeystrokes(proxy)
        }
    }
    
    private func eraseAndTypeKeystrokes(_ proxy: CGEventTapProxy) {
        for _ in characterKeystrokes {
            systemEvents.postEvent(.keyDown(Keystroke(.delete)), proxy)
            systemEvents.postEvent(.keyUp(Keystroke(.delete)), proxy)
        }
        typeCharacterKeystrokes(proxy)
    }
    
    private func typeCharacterKeystrokes(_ proxy: CGEventTapProxy) {
        for keystroke in characterKeystrokes {
            if keystroke.flags.contains(.maskShift) {
                systemEvents.postEvent(.shiftDown, proxy)
            }
            
            systemEvents.postEvent(.keyDown(keystroke), proxy)
            systemEvents.postEvent(.keyUp(keystroke), proxy)
            
            if keystroke.flags.contains(.maskShift) {
                systemEvents.postEvent(.shiftUp, proxy)
            }
        }
    }
}
