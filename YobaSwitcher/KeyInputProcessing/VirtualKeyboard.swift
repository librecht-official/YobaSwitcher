//
//  VirtualKeyboard.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

protocol VirtualKeyboardProtocol {
    func postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy)
    
    /// Returns keyboard layout mapping object for given text
    ///
    /// If language of the first character in text is English return En-Ru mapping, otherwise Ru-En
    func layoutMapping(for text: String) -> KeyboardLayoutMapping
    
    func selectedInputSource() -> InputSource
    func inputSource(forLanguage id: LanguageIdentifier) -> InputSource
    /// Selects first non-selected keyboard input source
    func switchInputSource()
}

final class VirtualKeyboard: VirtualKeyboardProtocol {
    func postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy) {
        let event = CGEvent.fromKeystrokeEvent(keystrokeEvent)
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
    
    func selectedInputSource() -> InputSource {
        InputSource(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue())
    }
    
    func inputSource(forLanguage id: LanguageIdentifier) -> InputSource {
        InputSource(TISCopyInputSourceForLanguage(id.rawValue as CFString).takeRetainedValue())
    }
    
    func switchInputSource() {
        let inputSourceCriteria = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true
        ]  as CFDictionary
        let sourceList = InputSource.fetchList(filter: inputSourceCriteria)
        
        guard let nonSelectedSource = sourceList.first(where: { !$0.isSelected }) else {
            return
        }
        
        TISSelectInputSource(nonSelectedSource.asTISInputSource)
        
        // TODO: Check kTISNotifySelectedKeyboardInputSourceChanged
    }
}

//CFNotificationCenterAddObserver(
//    CFNotificationCenterGetDistributedCenter(),
//    UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
//    { center, observer, _, _, _ in
//        Log.info("InputSourceChanged")
//        CFNotificationCenterRemoveObserver(center, observer, CFNotificationName(kTISNotifySelectedKeyboardInputSourceChanged), nil)
//    },
//    kTISNotifySelectedKeyboardInputSourceChanged,
//    nil,
//    .deliverImmediately
//)
