//
//  AppDelegate.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 01.01.2023.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let mainMenuController = MainMenuController()
    private let globalInputProcessing = GlobalInputProcessingManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainMenuController.start()
        globalInputProcessing.start()
    }
}
