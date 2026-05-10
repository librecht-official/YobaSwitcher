//
//  Created by Vladislav Librecht on 10.05.2026
//

import AppKit
import Carbon

struct PasteboardBasedSelectedTextExtractor {
    let pasteboard: NSPasteboard//Protocol
    
    init(pasteboard: NSPasteboard = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }
    
    func selectedText() throws -> String {
        let originalData = pasteboard.data(forType: .string)
//        let originalItems = pasteboard.pasteboardItems ?? []
        
        let pbChangeCountBeforeCopy = pasteboard.changeCount
        Log.debug("Pasteboard change count before Cmd+C: \(pbChangeCountBeforeCopy)")
        performCopyShortcut()
//        try await Task.sleep(nanoseconds: 100_000_000)
        Thread.sleep(forTimeInterval: 0.1)
        Log.debug("Pasteboard change count after Cmd+C: \(pasteboard.changeCount)")
        
        if pasteboard.changeCount == pbChangeCountBeforeCopy {
            // If change count hasn't change after 'copy' it means there was no selected text to copy
            throw TextError("Pasteboard has no string content")
        }
        
        let result = pasteboard.string(forType: .string)
        
        pasteboard.prepareForNewContents()
        pasteboard.setData(originalData, forType: .string)
//        pasteboard.writeObjects(originalItems)
        
        if let result = result {
            return result
        }
        throw TextError("Pasteboard has no string content")
    }
    
    func setSelectedText(_ newText: String) {
        let originalData = pasteboard.data(forType: .string)
        
        pasteboard.prepareForNewContents()
        pasteboard.setString(newText, forType: .string)
        
        let cmdV = [
            CGEvent.key(kVK_Command, down: true, .maskCommand),
            CGEvent.key(kVK_ANSI_V, down: true, .maskCommand),
            CGEvent.key(kVK_ANSI_V, down: false, .maskCommand),
            CGEvent.key(kVK_Command, down: false, []),
        ]
        cmdV.forEach { event in
            event?.post(tap: .cgSessionEventTap)
        }
        Thread.sleep(forTimeInterval: 0.1)
//        
        pasteboard.prepareForNewContents()
        pasteboard.setData(originalData, forType: .string)
    }
    
    private func performCopyShortcut() {
        let cmdC = [
            CGEvent.key(kVK_Command, down: true, .maskCommand),
            CGEvent.key(kVK_ANSI_C, down: true, .maskCommand),
            CGEvent.key(kVK_ANSI_C, down: false, .maskCommand),
            CGEvent.key(kVK_Command, down: false, []),
        ]
        cmdC.forEach { event in
            event?.post(tap: .cgSessionEventTap)
        }
    }
}

extension CGEvent {
    static func key(_ keyCode: Int, down: Bool, _ flags: CGEventFlags) -> Self? {
        let event = Self(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: down)
        event?.flags = flags
        return event
    }
}

struct TextError: LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var errorDescription: String? { message }
}
