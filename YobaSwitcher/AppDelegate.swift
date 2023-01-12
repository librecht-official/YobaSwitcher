//
//  AppDelegate.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let mainMenuController = MainMenuController()
    private let keyInputProcessing = KeyInputProcessingLauncher()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainMenuController.start()
        keyInputProcessing.launch()
    }
}
