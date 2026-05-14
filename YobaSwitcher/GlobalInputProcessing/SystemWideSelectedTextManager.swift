//
//  SelectedTextManager.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 12.01.2023.
//

protocol SelectedTextManager {
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLayout() -> Bool
    
    @discardableResult
    func changeSelectedTextCase() -> Bool
}

final class SystemWideSelectedTextManager: SelectedTextManager {
    let tisManager: TextInputSourceManager
    let systemWide: SystemWideAccessibility
    let textReaderWriter = PasteboardTextReaderWriter()
    
    init(tisManager: TextInputSourceManager, systemWide: SystemWideAccessibility) {
        self.tisManager = tisManager
        self.systemWide = systemWide
    }
    
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLayout() -> Bool {
        do {
            return try textReaderWriter.withSelectedText { selectedText, writeSelectedText in
                if selectedText.isEmpty {
                    Log.debug("Selected text is empty")
                    return false
                }
                
                let layoutMapping = tisManager.layoutMapping(for: selectedText)
                let translatedText = String(selectedText.map { layoutMapping[$0] })
                writeSelectedText(translatedText)
                
                let targetInputSource = tisManager.inputSource(forLanguage: layoutMapping.targetLanguage)
                if tisManager.currentKeyboardLayoutInputSource().id != targetInputSource.id {
                    tisManager.switchInputSource()
                }
                
                return true
            }
        } catch {
            Log.debug("Selected text not found: \(error)")
            return false
        }
    }
    
    @discardableResult
    func changeSelectedTextCase() -> Bool {
        guard let focusedElement = systemWide.focusedElement() else { return false }
        let selectedText = focusedElement.selectedText
        
        if selectedText.isEmpty {
            Log.debug("Selected text is empty")
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
