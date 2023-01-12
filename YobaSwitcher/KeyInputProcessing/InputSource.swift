//
//  InputSource.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//
// "Unmanaged" : https://nshipster.com/unmanaged/

import Carbon

struct InputSource {
    private let _guts: TISInputSource
    
    init(_ object: TISInputSource) {
        self._guts = object
    }
    
    var asTISInputSource: TISInputSource { _guts }
    
    func value<T>(key: CFString) -> T? {
        TISGetInputSourceProperty(_guts, key).map { Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() } as? T
    }
    
    var id: String? {
        value(key: kTISPropertyInputSourceID)
    }
    
    var isSelected: Bool {
        value(key: kTISPropertyInputSourceIsSelected) ?? false
    }
    
    static func fetchList(filter: CFDictionary) -> [InputSource] {
        guard let sources = TISCreateInputSourceList(filter, false).takeRetainedValue() as? [TISInputSource] else {
            Log.error("Failed to fetch input source list")
            return []
        }
        return sources.map(InputSource.init)
    }
}
