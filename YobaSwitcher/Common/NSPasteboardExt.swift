//
//  Created by Vladislav Librecht on 08.03.2023.
//

import Cocoa

// sourcery: AutoMockable
protocol NSPasteboardProtocol {
    var pasteboardItems: [NSPasteboardItem]? { get }
    
    var changeCount: Int { get }
    
    // sourcery: stubName = "stringForType"
    func string(forType dataType: NSPasteboard.PasteboardType) -> String?
    
    @discardableResult
    func setString(_ string: String, forType dataType: NSPasteboard.PasteboardType) -> Bool
    
    @discardableResult
    func prepareForNewContents() -> Int
    
    @discardableResult
    func writeObjects(_ objects: [any NSPasteboardWriting]) -> Bool
}

extension NSPasteboard: NSPasteboardProtocol {
    @discardableResult
    func prepareForNewContents() -> Int {
        prepareForNewContents(with: [])
    }
}

enum DI {
}

extension DI {
    #if TEST
    static var pasteboard: NSPasteboardProtocol = NSPasteboard.general
    #else
    static var pasteboard: NSPasteboard { NSPasteboard.general }
    #endif
}
