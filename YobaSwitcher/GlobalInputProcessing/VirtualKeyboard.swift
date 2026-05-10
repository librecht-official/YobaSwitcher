//
//  VirtualKeyboard.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

// sourcery: AutoMockable
protocol VirtualKeyboardProtocol {
    func postInputEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy)
    
    // sourcery: stubNameMode = "medium"
    /// Returns keyboard layout mapping object for given text
    ///
    /// If language of the first character in text is English return En-Ru mapping, otherwise Ru-En
    func layoutMapping(for text: String) -> KeyboardLayoutMapping
    
    func currentKeyboardLayoutInputSource() -> TextInputSource
    
    // sourcery: stubNameMode = "medium"
    func inputSource(forLanguage id: LanguageIdentifier) -> TextInputSource
    
    /// Selects first non-selected keyboard input source
    func switchInputSource()
    
    // sourcery: stubNameMode = "medium"
    func switchInputSource(completion: @escaping () -> ())
}

final class VirtualKeyboard<CGEvent: CoreGraphicsEvent>: VirtualKeyboardProtocol {
    let distributedNotificationCenter: DistributedNotificationCenterProtocol
    let inputSourceManager: TextInputSourceManager
    
    init(distributedNotificationCenter: DistributedNotificationCenterProtocol = DistributedNotificationCenter.default(), inputSourceManager: TextInputSourceManager = DefaultTextInputSourceManager()) {
        self.distributedNotificationCenter = distributedNotificationCenter
        self.inputSourceManager = inputSourceManager
        
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
    
    func postInputEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) {
        Log.debug(inputEvent)
        let event = CGEvent.fromInputEvent(inputEvent)
        event?.tapPostEvent(proxy)
    }
    
    func layoutMapping(for text: String) -> KeyboardLayoutMapping {
        let enToRu = KeyboardLayoutMapping.enToRu
        guard let firstCharacter = text.first else {
            return enToRu
        }
        if enToRu.hasKey(Character(firstCharacter.lowercased())) {
            return enToRu
        }
        return KeyboardLayoutMapping.ruToEn
    }
    
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        inputSourceManager.currentKeyboardLayoutInputSource()
    }
    
    func inputSource(forLanguage id: LanguageIdentifier) -> TextInputSource {
        inputSourceManager.inputSource(forLanguage: id.rawValue)
    }
    
    func switchInputSource() {
        switchInputSource(completion: {})
    }
    
    func switchInputSource(completion: @escaping () -> Void) {
        let criteria = [
            kTISPropertyInputSourceCategory!: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable!: true
        ]
        let sourceList = inputSourceManager.inputSourceList(filter: criteria)
        guard let nonSelectedSource = sourceList.first(where: { !$0.isSelected }) else {
            Log.debug("Input source to select not found")
            return
        }
        
        switchInputSourceCompletion = completion
        
        Log.debug("Selecting input source: \(nonSelectedSource.id)")
        nonSelectedSource.select()
    }
    
    private var switchInputSourceCompletion: (() -> Void)?
    
    @objc func selectedKeyboardInputSourceChanged(_ notification: Any) {
        Log.debug("""
            [DNC] Selected input source has changed.
            thread: \(Thread.current)
            notification: \(notification)
            completion: \(switchInputSourceCompletion)
            """)
        switchInputSourceCompletion?()
        switchInputSourceCompletion = nil
    }
}
