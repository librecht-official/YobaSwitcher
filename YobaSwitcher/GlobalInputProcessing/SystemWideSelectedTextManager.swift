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
    let systemWide = PasteboardTextReaderWriter()
    
    init(tisManager: TextInputSourceManager) {
        self.tisManager = tisManager
    }
    
    @discardableResult
    func replaceSelectedTextWithAlternativeKeyboardLayout() -> Bool {
        do {
            return try systemWide.withSelectedText { selectedText, writeSelectedText in
                if selectedText.isEmpty {
                    Log.selectedText.debug("Selected text is empty")
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
            Log.selectedText.debug("Selected text not found: \(error)")
            return false
        }
    }
    
    @discardableResult
    func changeSelectedTextCase() -> Bool {
        do {
            return try systemWide.withSelectedText { selectedText, writeSelectedText in
                if selectedText.isEmpty {
                    Log.selectedText.debug("Selected text is empty")
                    return false
                }
                
                let uppercasedText = selectedText.uppercased()
                if selectedText == uppercasedText {
                    writeSelectedText(selectedText.lowercased())
                } else {
                    writeSelectedText(uppercasedText)
                }
                
                return true
            }
        } catch {
            Log.selectedText.debug("Selected text not found: \(error)")
            return false
        }
    }
}
