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

// TODO: Rename
final class SystemWideSelectedTextManager: SelectedTextManager {
    let tisManager: TextInputSourceManager
    let systemWide: SystemWideAccessibility
    let textExtractor = PasteboardBasedSelectedTextExtractor()
    
    init(tisManager: TextInputSourceManager, systemWide: SystemWideAccessibility) {
        self.tisManager = tisManager
        self.systemWide = systemWide
    }
    
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLanguage() -> Bool {
//        guard let focusedElement = systemWide.focusedElement() else { return false }
//        let selectedText = focusedElement.selectedText
        do {
//            let selectedText = try textExtractor.selectedText()
            
            return try textExtractor.withSelectedText { selectedText in
                if selectedText.isEmpty {
                    Log.debug("Selected text is empty")
                    return false
                }
                
                let layoutMapping = tisManager.layoutMapping(for: selectedText)
                let translatedText = String(selectedText.map { layoutMapping[$0] })
                textExtractor.setSelectedText(translatedText)
                
    //            focusedElement.selectedText = translatedText
                
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
        
//        return true
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
