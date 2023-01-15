//
//  SystemWideAccessibility.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import ApplicationServices

// sourcery: AutoMockable
protocol SystemWideAccessibility {
    func focusedElement() -> FocusedUIElement?
}

final class SystemWide<UIElement: AccessibilityUIElement>: SystemWideAccessibility {
    private let systemWide = UIElement.systemWide
    
    func focusedElement() -> FocusedUIElement? {
        var focusedUIElementRef: CFTypeRef?
        systemWide.copyAttributeValue(kAXFocusedUIElementAttribute, &focusedUIElementRef)
        
        guard let focusedUIElement = focusedUIElementRef as? UIElement else {
            return nil
        }
        return FocusedUIElementAccessor<UIElement>(focusedUIElement)
    }
}
