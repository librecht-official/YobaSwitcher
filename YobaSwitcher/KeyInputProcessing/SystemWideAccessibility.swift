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
            Log.info("No focused element: \(result)")
            return nil
        }
        return FocusedUIElementAccessor(focusedUIElement as! AXUIElement)
    }
}
