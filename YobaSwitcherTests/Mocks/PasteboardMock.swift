//
//  Created by Vladislav Librecht on 14.05.2026
//

import Cocoa
import Testing
@testable import YobaSwitcher

final class PasteboardMock: NSPasteboardProtocol {
    var _initialItems: [NSPasteboardItem] = [
        build(NSPasteboardItem(), {
            $0.setData(Data("file:///.file/id=6571367.400663454".utf8), forType: .fileURL)
            $0.setData(Data("file.png".utf8), forType: .string)
        }),
    ]
    var _selectedText: String?
    
    var pasteboardItems: [NSPasteboardItem]?
    
    var changeCount: Int = 0
    
    init() {
        pasteboardItems = _initialItems
    }
    
    func string(forType dataType: NSPasteboard.PasteboardType) -> String? {
        #expect(dataType == .string)
        return _selectedText
    }
    
    @discardableResult
    func setString(_ string: String, forType dataType: NSPasteboard.PasteboardType) -> Bool {
        #expect(dataType == .string)
        _selectedText = string
        changeCount += 1
        return true
    }
    
    func prepareForNewContents() -> Int {
        if !pasteboardItems!.isEmpty {
            changeCount += 1
        }
        pasteboardItems = []
        return changeCount
    }
    
    func writeObjects(_ objects: [any NSPasteboardWriting]) -> Bool {
        pasteboardItems = objects.map { object in
            let item = NSPasteboardItem()
            let types = object.writableTypes(for: NSPasteboard.general)
            for type in types {
                if let data = object.pasteboardPropertyList(forType: type) as? Data {
                    item.setData(data, forType: type)
                }
            }
            return item
        }
        
        changeCount += 1
        return true
    }
}

extension NSPasteboardItem {
    var stringSnapshot: [NSPasteboard.PasteboardType: String] {
        var result: [NSPasteboard.PasteboardType: String] = [:]
        for type in types {
            result[type] = string(forType: type)
            #expect(result[type] != nil)
        }
        return result
    }
    
    open override var description: String {
        stringSnapshot.description
    }
}

extension NSPasteboardItem {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? NSPasteboardItem else {
            return false
        }
        return stringSnapshot == other.stringSnapshot
    }
}
