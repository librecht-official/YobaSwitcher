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
    
    func switchInputSource()
}

final class VirtualKeyboard: VirtualKeyboardProtocol {
    func postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy) {
        let event = CGEvent.fromKeystrokeEvent(keystrokeEvent)
        event?.tapPostEvent(proxy)
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
