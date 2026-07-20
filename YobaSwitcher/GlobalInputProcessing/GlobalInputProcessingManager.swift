//
//  GlobalInputProcessingManager.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Cocoa

/// Facade for global input processing solution
final class GlobalInputProcessingManager {
    let inputMonitor: GlobalInputMonitorProtocol
    
    private var timer: Timer?
    
    init() {
        let inputSourceManager = DefaultTextInputSourceManager()
        let inputProcessingController = GlobalInputProcessor<CGEvent>(
            selectedTextManager: SystemWideSelectedTextManager(tisManager: inputSourceManager),
            inputSourceManager: inputSourceManager
        )
        self.inputMonitor = GlobalInputMonitor(handler: inputProcessingController)
    }
    
    func start() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as CFString: true] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            inputMonitor.start()
        } else {
            // TODO: Show window with hint
            Log.inputProcessing.error("Accessibility is not allowed for this app")
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.relaunchIfProcessTrusted()
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
