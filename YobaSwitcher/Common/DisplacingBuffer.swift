//
//  Buffer.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 14.01.2023.
//

/// An ordered, random-access collection with limited size.
///
/// When adding a new element, if there is no space the buffer removes first element.
struct DisplacingBuffer<Element>: RandomAccessCollection {
    typealias Index = Int
    
    let maxSize: Int
    
    private var storage: [Element] = []
    
    init(maxSize: Int, storage: [Element] = []) {
        self.maxSize = maxSize
        self.storage = storage
    }
    
    var startIndex: Int { storage.startIndex }
    
    var endIndex: Int { storage.endIndex }
    
    subscript(position: Int) -> Element {
        _read {
            yield storage[position]
        }
    }
    
    mutating func append(_ newElement: Element) {
        if storage.count >= maxSize {
            storage.removeFirst()
        }
        storage.append(newElement)
    }
}

extension DisplacingBuffer: CustomStringConvertible {
    var description: String { storage.description }
}

extension DisplacingBuffer: CustomDebugStringConvertible {
    var debugDescription: String { storage.debugDescription }
}

