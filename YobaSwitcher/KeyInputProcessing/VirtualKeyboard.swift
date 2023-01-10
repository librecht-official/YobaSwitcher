//
//  VirtualKeyboard.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Carbon
import CoreGraphics

protocol VirtualKeyboardProtocol {
    func postKeyDown(_ keyCode: Int, _ proxy: CGEventTapProxy)
    func postKeyUp(_ keyCode: Int, _ proxy: CGEventTapProxy)
    
    func switchInputSource()
}

final class VirtualKeyboard: VirtualKeyboardProtocol {
    func postKeyDown(_ keyCode: Int, _ proxy: CGEventTapProxy) {
        CGEvent.keyDown(CGKeyCode(keyCode))?.tapPostEvent(proxy)
    }
    
    func postKeyUp(_ keyCode: Int, _ proxy: CGEventTapProxy) {
        CGEvent.keyUp(CGKeyCode(keyCode))?.tapPostEvent(proxy)
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
    }
}
