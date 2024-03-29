//
//  SelectedTextManager.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 12.01.2023.
//

// sourcery: AutoMockable
protocol SelectedTextManager {
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool
    
    @discardableResult
    func changeSelectedTextCase() -> Bool
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
        if keyboard.currentKeyboardLayoutInputSource().id != targetInputSource.id {
            keyboard.switchInputSource()
        }
        
        return true
    }
    
    @discardableResult
    func changeSelectedTextCase() -> Bool {
        guard let focusedElement = systemWide.focusedElement() else { return false }
        let selectedText = focusedElement.selectedText
        
        if selectedText.isEmpty {
            Log.info("Selected text is empty")
            return false
        }
        let uppercasedText = selectedText.uppercased()
        if selectedText == uppercasedText {
            focusedElement.selectedText = selectedText.lowercased()
        } else {
            focusedElement.selectedText = uppercasedText
        }
        
        return true
    }
}
