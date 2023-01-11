//
//  AppDelegate.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let keyInputManager = KeyInputManager()
    private var timer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        if !AXIsProcessTrustedWithOptions(options) {
            Log.info("Accessibility is not allowed for this app")
//            timer = Timer.scheduledTimer(
//                withTimeInterval: 3.0,
//                repeats: true
//            ) { _ in self.relaunchIfProcessTrusted() }
        }

        keyInputManager.start()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
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
