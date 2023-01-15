//
//  FocusedUIElement.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import ApplicationServices

// sourcery: AutoMockable
protocol FocusedUIElement {
    var selectedText: String { get nonmutating set }
}

final class FocusedUIElementAccessor<UIElement: AccessibilityUIElement>: FocusedUIElement {
    private let element: UIElement
    
    init(_ element: UIElement) {
        self.element = element
    }
    
    var selectedText: String {
        get {
            var selectedTextRef: CFTypeRef?
            element.copyAttributeValue(kAXSelectedTextAttribute, &selectedTextRef)
            return (selectedTextRef as? String) ?? ""
        }
        set {
            var isSettable = DarwinBoolean(false)
            element.isAttributeSettable(kAXSelectedTextAttribute, &isSettable)

            if isSettable.boolValue {
                element.setAttributeValue(kAXSelectedTextAttribute, newValue as CFString)
            }
        }
    }
}
