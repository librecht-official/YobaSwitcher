//
//  MainMenuController.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import Cocoa

final class MainMenuController {
    private var statusItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    
    func start() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "keyboard.fill", accessibilityDescription: "Status bar icon")
        
        let about = NSMenuItem()
        about.title = "YobaSwitcher - Version \(Bundle.main.applicationVersion ?? "unknown")"
        
        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.target = self
        quitItem.action = #selector(quit)
        
        statusBarMenu = NSMenu(title: "Yoba Switcher")
        statusBarMenu.addItem(about)
        statusBarMenu.addItem(quitItem)
        
        statusItem.menu = statusBarMenu
    }
    
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
}

extension Bundle {
    var applicationVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
