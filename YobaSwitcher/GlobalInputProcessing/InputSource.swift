//
//  InputSource.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 10.01.2023.
//
// About `Unmanaged` : https://nshipster.com/unmanaged/

import Carbon

//struct TextInputSourceBox<TIS: TextInputSourceAPI> {
//    private let ref: TIS.TextInputSource
//    
//    init(_ object: TIS.TextInputSource) {
//        self.ref = object
//    }
//    
//    func value<T>(key: CFString) -> T? {
//        TIS.getInputSourceProperty(ref, key).map { Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() } as? T
//    }
//}

// sourcery: AutoMockable
protocol TextInputSourceManager {
    func currentKeyboardLayoutInputSource() -> TextInputSource
    func inputSource(forLanguage id: String) -> TextInputSource
    func inputSourceList(filter: [CFString: Any]) -> [TextInputSource]
}

struct DefaultTextInputSourceManager: TextInputSourceManager {
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        TextInputSource(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue())
    }

    func inputSource(forLanguage id: String) -> TextInputSource {
        TextInputSource(TISCopyInputSourceForLanguage(id as CFString).takeRetainedValue())
    }
    
    func inputSourceList(filter: [CFString: Any]) -> [TextInputSource] {
        guard let sources = TISCreateInputSourceList(filter as CFDictionary, false).takeRetainedValue() as? [TISInputSource] else {
            Log.error("Failed to fetch input source list")
            return []
        }
        
        return sources.map(TextInputSource.init)
    }
}

struct TextInputSource: Equatable {
    static func == (lhs: TextInputSource, rhs: TextInputSource) -> Bool {
        lhs.ref.isEqual(to: rhs.ref)
    }
    
    private let ref: any TextInputSourceReference
    
    init(_ object: any TextInputSourceReference) {
        self.ref = object
    }
    
    var id: String? {
        ref.value(key: kTISPropertyInputSourceID)
    }
    
    var isSelected: Bool {
        ref.value(key: kTISPropertyInputSourceIsSelected) ?? false
    }
    
    func select() {
        ref.select()
    }
}

protocol TextInputSourceReference: AnyObject, Equatable {
    func value<T>(key: CFString) -> T?
    func select()
    
    func isEqual(to other: any TextInputSourceReference) -> Bool
}

extension TextInputSourceReference {
    func isEqual(to other: any TextInputSourceReference) -> Bool {
        guard let casted = other as? Self else {
            return false
        }
        return self == casted
    }
}

extension TISInputSource: TextInputSourceReference {
    func value<T>(key: CFString) -> T? {
        TISGetInputSourceProperty(self, key).map { Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() } as? T
    }
    
    func select() {
        TISSelectInputSource(self)
    }
}

//// sourcery: AutoMockable
//protocol TextInputSourceProtocol: AnyObject {
//    var id: String? { get }
//}
//
//extension TISInputSource: TextInputSourceProtocol {
//    func value<T>(key: CFString) -> T? {
//        TISGetInputSourceProperty(self, key).map { Unmanaged<AnyObject>.fromOpaque($0).takeUnretainedValue() } as? T
//    }
//
//    var id: String? {
//        value(key: kTISPropertyInputSourceID)
//    }
//}

//// sourcery: AutoMockable
//protocol TextInputSourceAPI {
//    associatedtype TextInputSource: TextInputSourceProtocol
//    
//    static func copyCurrentKeyboardLayoutInputSource() -> Unmanaged<TextInputSource>!
//    
//    static func getInputSourceProperty(_ inputSource: TextInputSource!, _ propertyKey: CFString!) -> UnsafeMutableRawPointer!
//}
//
//enum TIS: TextInputSourceAPI {
//    typealias TextInputSource = TISInputSource
//    
//    static func copyCurrentKeyboardLayoutInputSource() -> Unmanaged<TextInputSource>! {
//        TISCopyCurrentKeyboardLayoutInputSource()
//    }
//    
//    static func getInputSourceProperty(_ inputSource: TextInputSource!, _ propertyKey: CFString!) -> UnsafeMutableRawPointer! {
//        TISGetInputSourceProperty(inputSource, propertyKey)
//    }
//}
