//
//  KeyInputProcessingLauncher.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import Cocoa

final class KeyInputProcessingLauncher {
    private let keyInputManager = KeyInputManager()
    private var timer: Timer?
    
    func launch() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as CFString: true] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            keyInputManager.start()
        } else {
            Log.info("Accessibility is not allowed for this app")
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                self.relaunchIfProcessTrusted()
            }
        }
    }
    
    private func relaunchIfProcessTrusted() {
        if AXIsProcessTrusted() {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: Bundle.main.executablePath!)
            try! task.run()
            NSApplication.shared.terminate(self)
        }
    }
}
