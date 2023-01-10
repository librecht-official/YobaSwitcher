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
        self.keyInputController = KeyInputController()
        self.inputMonitor = inputMonitor
    }
    
    func start() {
        inputMonitor.delegate = keyInputController
        inputMonitor.start()
    }
}
