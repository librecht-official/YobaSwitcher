//
//  InputSource.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//
// About `Unmanaged` : https://nshipster.com/unmanaged/

import Carbon

protocol TextInputSourceAPI {
    func currentKeyboardLayoutInputSource() -> TextInputSource
    func inputSource(forLanguage id: String) -> TextInputSource
    func inputSourceList(filter: [CFString: Any]) -> [TextInputSource]
}

struct TIS: TextInputSourceAPI {
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        TextInputSource(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue())
    }

    func inputSource(forLanguage id: String) -> TextInputSource {
        TextInputSource(TISCopyInputSourceForLanguage(id as CFString).takeRetainedValue())
    }
    
    func inputSourceList(filter: [CFString: Any]) -> [TextInputSource] {
        guard let sources = TISCreateInputSourceList(filter as CFDictionary, false).takeRetainedValue() as? [TISInputSource] else {
            Log.inputSource.error("Failed to fetch input source list")
            return []
        }
        
        return sources.map(TextInputSource.init)
    }
}

struct TextInputSource {
    fileprivate let ref: any TextInputSourceReference
    
    init(_ object: any TextInputSourceReference) {
        self.ref = object
    }
    
    var id: String? {
        ref.value(key: kTISPropertyInputSourceID)
    }
    
    func select() {
        ref.select()
    }
}

protocol TextInputSourceReference: AnyObject, Equatable {
    func value<T>(key: CFString) -> T?
    func select()
}

extension TISInputSource: TextInputSourceReference {
    func value<T>(key: CFString) -> T? {
        TISGetInputSourceProperty(self, key).map { Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() } as? T
    }
    
    func select() {
        TISSelectInputSource(self)
    }
}
