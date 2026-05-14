//
//  Created by Vladislav Librecht on 10.05.2026
//

import AppKit

struct PasteboardTextReaderWriter {
    let pasteboard = StaticDependency.pasteboard
    let systemEvents = StaticDependency.systemEvents
    
    typealias Writer = (String) -> Void
    
    func withSelectedText<R>(_ action: (String, Writer) throws -> R) throws -> R {
        let originalItems = pasteboard.pasteboardItems ?? []
        let pasteboardStash = originalItems.map(PasteboardItemStash.init)
        
        defer {
            pasteboard.prepareForNewContents()
            pasteboard.writeObjects(pasteboardStash)
        }
        
        let text = try readSelectedText()
        return try action(text, writeSelectedText)
    }
    
    private func readSelectedText() throws -> String {
        let pbChangeCountBeforeCopy = pasteboard.changeCount
        Log.debug("Pasteboard change count before Cmd+C: \(pbChangeCountBeforeCopy)")
        performCopyShortcut()
        Log.debug("Pasteboard change count after Cmd+C: \(pasteboard.changeCount)")
        
        if pasteboard.changeCount == pbChangeCountBeforeCopy {
            // If 'change count' hasn't change after 'copy' it means there was no selected text to copy
            throw TextError("Pasteboard content has not change after 'copy' thus no selected text")
        }
        
        let result = pasteboard.string(forType: .string)
        
        guard let result else {
            throw TextError("Pasteboard has no string content")
        }
        return result
    }
    
    private func writeSelectedText(_ newText: String) {
        pasteboard.prepareForNewContents()
        pasteboard.setString(newText, forType: .string)
        
        performPasteShortcut()
    }
    
    private func performCopyShortcut() {
        let cmdC: [InputEvent] = [
            .flagsChanged(Keystroke(.command, flags: .maskCommand), keyDown: true),
            .keyDown(Keystroke(.c, flags: .maskCommand)),
            .keyUp(Keystroke(.c, flags: .maskCommand)),
            .flagsChanged(Keystroke(.command, flags: []), keyDown: false),
        ]
        cmdC.forEach {
            systemEvents.postEvent($0, at: .cgSessionEventTap)
        }
        #if !TEST
        Thread.sleep(forTimeInterval: 0.1)
        #endif
    }
    
    private func performPasteShortcut() {
        let cmdV: [InputEvent] = [
            .flagsChanged(Keystroke(.command, flags: .maskCommand), keyDown: true),
            .keyDown(Keystroke(.v, flags: .maskCommand)),
            .keyUp(Keystroke(.v, flags: .maskCommand)),
            .flagsChanged(Keystroke(.command, flags: []), keyDown: false),
        ]
        cmdV.forEach {
            systemEvents.postEvent($0, at: .cgSessionEventTap)
        }
        #if !TEST
        Thread.sleep(forTimeInterval: 0.1)
        #endif
    }
}

// MARK: -

/// Auxilary type that helps to stash/restore pasteboard content between copy-paste operations
///
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
