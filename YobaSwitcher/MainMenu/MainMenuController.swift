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
        
        let quitItem = NSMenuItem()
        quitItem.title = "Quit"
        quitItem.target = self
        quitItem.action = #selector(quit)
        
        statusBarMenu = NSMenu(title: "Yoba Switcher")
        statusBarMenu.addItem(quitItem)
        
        statusItem.menu = statusBarMenu
    }
    
    @objc
    func quit() {
        NSApplication.shared.terminate(self)
    }
}
