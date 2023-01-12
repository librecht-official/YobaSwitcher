//
//  SelectedTextManager.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 12.01.2023.
//

import Foundation

protocol SelectedTextManager {
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool
}

final class SystemWideSelectedTextManager: SelectedTextManager {
    let keyboard: VirtualKeyboardProtocol
    let systemWide: SystemWideAccessibility
    
    init(keyboard: VirtualKeyboardProtocol, systemWide: SystemWideAccessibility) {
        self.keyboard = keyboard
        self.systemWide = systemWide
    }
    
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool {
        guard let focusedElement = systemWide.focusedElement() else { return false }
        let selectedText = focusedElement.selectedText
        
        if selectedText.isEmpty {
            Log.info("Selected text is empty")
            return false
        }
        
        let layoutMapping = keyboard.layoutMapping(for: selectedText)
        let translatedText = String(selectedText.map { layoutMapping[$0] })
        focusedElement.selectedText = translatedText
        
        let targetInputSource = keyboard.inputSource(forLanguage: layoutMapping.targetLanguage)
        if keyboard.selectedInputSource().id != targetInputSource.id {
            keyboard.switchInputSource()
        }
        
        return true
    }
}
