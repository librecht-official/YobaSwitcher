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
        self.keyInputController = KeyInputController(keyboard: VirtualKeyboard(), systemWide: SystemWide())
        self.inputMonitor = inputMonitor
    }
    
    func start() {
        inputMonitor.handler = keyInputController
        inputMonitor.start()
    }
}
