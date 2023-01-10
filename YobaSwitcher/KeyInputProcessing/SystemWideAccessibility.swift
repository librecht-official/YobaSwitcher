//
//  SystemWideAccessibility.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import ApplicationServices

protocol SystemWideAccessibility {
    func focusedElement() -> FocusedUIElement?
}

struct SystemWide: SystemWideAccessibility {
    private let systemWide = AXUIElementCreateSystemWide()
    
    func focusedElement() -> FocusedUIElement? {
        var focusedUIElementRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedUIElementRef)
        guard let focusedUIElement = focusedUIElementRef, CFGetTypeID(focusedUIElement) == AXUIElementGetTypeID(), result == .success else {
            print("No focused element: \(result)")
            return nil
        }
        return FocusedUIElementAccessor(focusedUIElement as! AXUIElement)
    }
}

protocol FocusedUIElement {
    var selectedText: String { get nonmutating set }
}

struct FocusedUIElementAccessor: FocusedUIElement {
    private let element: AXUIElement
    
    init(_ element: AXUIElement) {
        self.element = element
    }
    
    var selectedText: String {
        get {
            var selectedTextRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedTextRef)
            guard let selectedText = selectedTextRef as? String, result == .success else {
                print("No selected text: \(result)")
                return ""
            }
            return selectedText
        }
        nonmutating set {
            var isSettable = DarwinBoolean(false)
            AXUIElementIsAttributeSettable(element, kAXSelectedTextAttribute as CFString, &isSettable)
            print("isSettable: \(isSettable)")

            if isSettable.boolValue {
                let result = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, newValue as CFString)
                print("result: \(result)")
            }
        }
    }
}
