//
//  KeyInputManager.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Foundation

final class KeyInputManager {
    let keyInputController: KeyInputController
    let inputMonitor: GlobalInputMonitorProtocol
    
    init(inputMonitor: GlobalInputMonitorProtocol = GlobalInputMonitor()) {
        let keyboard = VirtualKeyboard()
        let systemWide = SystemWide()
        self.keyInputController = KeyInputController(
            selectedTextManager: SystemWideSelectedTextManager(keyboard: keyboard, systemWide: systemWide),
            keyboard: keyboard,
            systemWide: systemWide
        )
        self.inputMonitor = inputMonitor
    }
    
    func start() {
        inputMonitor.handler = keyInputController
        inputMonitor.start()
    }
}
