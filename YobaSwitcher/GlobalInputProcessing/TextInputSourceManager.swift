//
//  VirtualKeyboard.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

protocol TextInputSourceManager {
    /// Returns keyboard layout mapping object for given text
    ///
    /// If language of the first character in text is English return En-Ru mapping, otherwise Ru-En
    func layoutMapping(for text: String) -> KeyboardLayoutMapping
    
    func currentKeyboardLayoutInputSource() -> TextInputSource
    
    func inputSource(forLanguage id: LanguageIdentifier) -> TextInputSource
    
    /// Selects first non-selected keyboard input source
    func switchInputSource()
    
    func switchInputSource(completion: @escaping () -> ())
}

final class DefaultTextInputSourceManager: TextInputSourceManager {
    let distributedNotificationCenter: DistributedNotificationCenterProtocol
    let tis: TextInputSourceAPI
    
    init(distributedNotificationCenter: DistributedNotificationCenterProtocol = DistributedNotificationCenter.default(), tis: TextInputSourceAPI = TIS()) {
        assert(Thread.isMainThread, "DefaultTextInputSourceManager is supposed to be used in main thread")
        
        self.distributedNotificationCenter = distributedNotificationCenter
        self.tis = tis
        
        distributedNotificationCenter.addObserver(
            self,
            selector: #selector(selectedKeyboardInputSourceChanged),
            name: .selectedKeyboardInputSourceChanged,
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
    }
    
    deinit {
        distributedNotificationCenter.removeObserver(self, name: nil, object: nil)
    }
    
    func layoutMapping(for text: String) -> KeyboardLayoutMapping {
        let enToRu = KeyboardLayoutMapping.enToRu
        guard let firstCharacter = text.first(where: \.isLetter) else {
            return enToRu
        }
        if enToRu.hasKey(Character(firstCharacter.lowercased())) {
            return enToRu
        }
        return KeyboardLayoutMapping.ruToEn
    }
    
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        tis.currentKeyboardLayoutInputSource()
    }
    
    func inputSource(forLanguage id: LanguageIdentifier) -> TextInputSource {
        tis.inputSource(forLanguage: id.rawValue)
    }
    
    func switchInputSource() {
        switchInputSource(completion: {})
    }
    
    func switchInputSource(completion: @escaping () -> Void) {
        let criteria = [
            kTISPropertyInputSourceCategory!: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable!: true,
            kTISPropertyInputSourceIsSelected!: false
        ]
        let sourceList = tis.inputSourceList(filter: criteria)
        guard let nonSelectedSource = sourceList.first else {
            Log.inputSource.debug("Input source to select not found")
            return
        }
        
        switchInputSourceCompletion = completion
        
        Log.inputSource.debug("Selecting input source: \(nonSelectedSource.id)")
        nonSelectedSource.select()
    }
    
    private var switchInputSourceCompletion: (() -> Void)?
    
    @objc func selectedKeyboardInputSourceChanged(_ notification: Any) {
        Log.inputSource.debug("[DNC] Selected input source has changed.\n notification: \(String(describing: notification))\n current input source: \(self.currentKeyboardLayoutInputSource().id)\n completion: \(self.switchInputSourceCompletion)")
        switchInputSourceCompletion?()
        switchInputSourceCompletion = nil
    }
}
