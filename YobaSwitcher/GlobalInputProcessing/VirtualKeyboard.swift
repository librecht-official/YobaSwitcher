//
//  VirtualKeyboard.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//
// "Unmanaged" : https://nshipster.com/unmanaged/

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
    
    func currentKeyboardLayoutInputSource() -> InputSource
    
    // sourcery: stubNameMode = "medium"
    func inputSource(forLanguage id: LanguageIdentifier) -> InputSource
    
    /// Selects first non-selected keyboard input source
    func switchInputSource()
    
    // sourcery: stubNameMode = "medium"
    func switchInputSource(completion: @escaping () -> ())
}

final class VirtualKeyboard: VirtualKeyboardProtocol {
    func postInputEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) {
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
    
    func currentKeyboardLayoutInputSource() -> InputSource {
        InputSource(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue())
    }
    
    func inputSource(forLanguage id: LanguageIdentifier) -> InputSource {
        InputSource(TISCopyInputSourceForLanguage(id.rawValue as CFString).takeRetainedValue())
    }
    
    func switchInputSource() {
        switchInputSource(completion: {})
    }
    
    func switchInputSource(completion: @escaping () -> ()) {
        let sourceList = selectCapableKeyboardInputSourceList()
        guard let nonSelectedSource = sourceList.first(where: { !$0.isSelected }) else { return }
        
        // FIXME: Quickly press Option twice -> Input source changes 2 times, text is typed in wrong kb layout
        let center = DistributedNotificationCenter.default
        _ = center.addObserver(forName: .selectedKeyboardInputSourceChanged, suspensionBehavior: .deliverImmediately) { token, _ in
            center.removeObserver(token, name: .selectedKeyboardInputSourceChanged)
            completion()
        }
        
        TISSelectInputSource(nonSelectedSource.asTISInputSource)
    }
    
    func selectCapableKeyboardInputSourceList() -> [InputSource] {
        let criteria = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true
        ] as CFDictionary
        guard let sources = TISCreateInputSourceList(criteria, false).takeRetainedValue() as? [TISInputSource] else {
            Log.error("Failed to fetch input source list")
            return []
        }
        
        return sources.map(InputSource.init)
    }
}
