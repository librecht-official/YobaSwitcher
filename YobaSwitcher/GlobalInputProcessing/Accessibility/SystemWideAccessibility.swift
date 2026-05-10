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
        {
            let (ref1, error1) = systemWide._copyAttributeValue(kAXFocusedApplicationAttribute)
            
            let focusedApp = ref1 as? UIElement
            print("focused app: \(focusedApp)\n    error: \(error1)")
//            print(focusedApp?._copyAttributeNames())
            
            
            let windowRef = focusedApp?._copyAttributeValue(kAXFocusedWindowAttribute)
            print("focused window: \(windowRef?.0)\n    error: \(windowRef?.1)")
            
            let focusedElementRef = focusedApp?._copyAttributeValue(kAXFocusedUIElementAttribute)
            print("focused element: \(focusedElementRef)")
            
            let focusedElement = focusedElementRef?.0 as? UIElement
            let selectedTextRef = focusedElement?._copyAttributeValue("AXSelectedText")
            print("selectedTextRef: \(selectedTextRef)")
            
            let selectedTextEl = selectedTextRef?.0 as? String
            print("selectedTextEl: \(selectedTextEl)")
//            print(selectedTextEl?._copyAttributeNames())
            
        }()
        
        var focusedUIElementRef: CFTypeRef?
        systemWide.copyAttributeValue(kAXFocusedUIElementAttribute, &focusedUIElementRef)
        
        guard let focusedUIElement = focusedUIElementRef as? UIElement else {
            return nil
        }
        return FocusedUIElementAccessor<UIElement>(focusedUIElement)
    }
}
