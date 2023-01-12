//
//  main.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import Cocoa

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.setActivationPolicy(.accessory)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
