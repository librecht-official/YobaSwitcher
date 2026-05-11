//
//  Created by Vladislav Librecht on 10.05.2026
//

import AppKit
import Carbon

class PasteboardItemStash: NSObject, NSPasteboardWriting {
    private let types: [NSPasteboard.PasteboardType]
    private var plistsForType: [NSPasteboard.PasteboardType: Any] = [:]
    
    init(source: NSPasteboardItem) {
        self.types = source.types
        for type in types {
            plistsForType[type] = source.propertyList(forType: type)
        }
    }
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        Log.debug("writable types: \(types)")
        return types
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        let plist = plistsForType[type]
        Log.debug("plist for type \(type): \(plist)")
        return plist
    }
}

struct PasteboardBasedSelectedTextExtractor {
    let pasteboard: NSPasteboard//Protocol
    
    init(pasteboard: NSPasteboard = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }
    
    // TODO: Clean up
    func withSelectedText<R>(_ action: (String) throws -> R) throws -> R {
        let originalItems = pasteboard.pasteboardItems ?? []
        let pasteboardStash = originalItems.map(PasteboardItemStash.init)
        
        let text = try selectedText()
        
        defer {
            pasteboard.prepareForNewContents()
            pasteboard.writeObjects(pasteboardStash)
        }
        
        return try action(text)
    }
    
    func selectedText() throws -> String {
//        let originalItems = pasteboard.pasteboardItems ?? []
//        let pasteboardStash = originalItems.map(PasteboardItemStash.init)
        
        let pbChangeCountBeforeCopy = pasteboard.changeCount
        Log.debug("Pasteboard change count before Cmd+C: \(pbChangeCountBeforeCopy)")
        performCopyShortcut()
        Log.debug("Pasteboard change count after Cmd+C: \(pasteboard.changeCount)")
        
        if pasteboard.changeCount == pbChangeCountBeforeCopy {
            // If change count hasn't change after 'copy' it means there was no selected text to copy
            throw TextError("Pasteboard content has not change after 'copy' thus no selected text")
        }
        
        let result = pasteboard.string(forType: .string)
        
//        pasteboard.prepareForNewContents()
//        pasteboard.writeObjects(pasteboardStash)
        
        guard let result else {
            throw TextError("Pasteboard has no string content")
        }
        return result
    }
    
    func setSelectedText(_ newText: String) {
//        let originalItems = pasteboard.pasteboardItems ?? []
//        let pasteboardStash = originalItems.map(PasteboardItemStash.init)
        
        pasteboard.prepareForNewContents()
        pasteboard.setString(newText, forType: .string)
        
        performPasteShortcut()
        
//        pasteboard.prepareForNewContents()
//        pasteboard.writeObjects(pasteboardStash)
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
//        try await Task.sleep(nanoseconds: 100_000_000)
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    private func performPasteShortcut() {
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
