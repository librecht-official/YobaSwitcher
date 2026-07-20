//
//  GlobalInputProcessor.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Carbon
import CoreGraphics

final class GlobalInputProcessor<Event: HIDEvent>: GlobalInputHandler {
    
    let selectedTextManager: SelectedTextManager
    let inputSourceManager: TextInputSourceManager
    let systemEvents = StaticDependency.systemEvents
    
    // Contains latest character keys that will be retyped with alternative input source when the user taps Option key
    private(set) var characterKeystrokes: [Keystroke] = []
    private(set) var latestInputEvents = DisplacingBuffer<InputEvent>(maxSize: 3)
    
    init(selectedTextManager: SelectedTextManager, inputSourceManager: TextInputSourceManager) {
        self.selectedTextManager = selectedTextManager
        self.inputSourceManager = inputSourceManager
    }

    // MARK: GlobalInputHandler
    
    func handleEvent(event: Event, proxy: CGEventTapProxy) -> Event? {
        switch event.type {
        case .keyDown:
            return handleKeyDown(event: event, proxy: proxy)
        case .keyUp:
            return handleKeyUp(event: event, proxy: proxy)
        case .flagsChanged:
            return handleFlagsChange(event: event, proxy: proxy)
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            return handleMouseDown(event: event, proxy: proxy)
        default:
            return event
        }
    }
    
    private func handleKeyDown(event: Event, proxy: CGEventTapProxy) -> Event? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.key(.down, keystroke))
        updateCharacterKeystrokes(withNew: keystroke)
        
        if latestInputEvents.last.matches(Patterns.ctrlOptZ) {
            Log.inputProcessing.debug("Hit Ctrl+Opt+Z")
            selectedTextManager.changeSelectedTextCase()
            return nil
        }
        
        return event
    }
    
    private func handleKeyUp(event: Event, proxy: CGEventTapProxy) -> Event? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.key(.up, keystroke))
        
        return event
    }
    
    private func handleFlagsChange(event: Event, proxy: CGEventTapProxy) -> Event? {
        let keystroke = Keystroke(event: event)
        latestInputEvents.append(.flagsChanged(keystroke))
        
        let last2 = latestInputEvents.suffix(2)
        
        if last2.matches(Patterns.optionPress) || last2.matches(Patterns.optionPressWithCapslock) {
            Log.inputProcessing.debug("Hit Option")
            
            if characterKeystrokes.isEmpty {
                Log.inputProcessing.debug("Character keystrokes is empty")
                
                selectedTextManager.replaceSelectedTextWithAlternativeKeyboardLayout()
            } else {
                retypeCharacterKeystrokes(proxy)
            }
        }
        
        return event
    }
    
    private func handleMouseDown(event: Event, proxy: CGEventTapProxy) -> Event? {
        latestInputEvents.append(.mouseDown)
        characterKeystrokes = []
        
        return event
    }
    
    // MARK: Helpers
    
    private func updateCharacterKeystrokes(withNew keystroke: Keystroke) {
        if keystroke.keyCode.isDelete {
            if !characterKeystrokes.isEmpty {
                characterKeystrokes.removeLast()
            }
            return
        }
        
        if !keystroke.keyCode.isCharacterProducingKey || keystroke.isItPresumablyShortCut {
            characterKeystrokes = []
            return
        }
        
        if !keystroke.isAutorepeat {
            characterKeystrokes.append(keystroke)
        }
    }
    
    private func retypeCharacterKeystrokes(_ proxy: CGEventTapProxy) {
        if characterKeystrokes.isEmpty { return }
        
        Log.inputProcessing.debug("Retype character keystrokes: \(self.characterKeystrokes)")
        
        inputSourceManager.switchInputSource { [weak self] in
            self?.eraseAndTypeKeystrokes(proxy)
        }
    }
    
    private func eraseAndTypeKeystrokes(_ proxy: CGEventTapProxy) {
        for _ in characterKeystrokes {
            systemEvents.postEvent(.key(.down, Keystroke(.delete)), proxy)
            systemEvents.postEvent(.key(.up, Keystroke(.delete)), proxy)
        }
        typeCharacterKeystrokes(proxy)
    }
    
    private func typeCharacterKeystrokes(_ proxy: CGEventTapProxy) {
        // Simulate Shift hold: For example if we have 'HI'.
        // Instead of: Shift↓, H↓, H↑, Shift↑, Shift↓, I↓, I↑, Shift↑
        // We have:    Shift↓, H↓, H↑, I↓, I↑, Shift↑
        var shift = false
        for keystroke in characterKeystrokes {
            if !shift && keystroke.flags.contains(.maskShift) {
                systemEvents.postEvent(.shiftDown, proxy)
                shift = true
            }
            if shift && !keystroke.flags.contains(.maskShift) {
                systemEvents.postEvent(.shiftUp, proxy)
                shift = false
            }
            
            systemEvents.postEvent(.key(.down, keystroke), proxy)
            systemEvents.postEvent(.key(.up, keystroke), proxy)
        }
        if shift {
            systemEvents.postEvent(.shiftUp, proxy)
        }
    }
}

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
        .key(.down, Keystroke(.z, flags: [.maskControl, .maskAlternate]))
}
