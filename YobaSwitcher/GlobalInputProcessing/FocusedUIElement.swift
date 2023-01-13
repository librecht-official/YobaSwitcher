//
//  FocusedUIElement.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import ApplicationServices

protocol FocusedUIElement {
    var selectedText: String { get nonmutating set }
}

final class FocusedUIElementAccessor: FocusedUIElement {
    private let element: AXUIElement
    
    init(_ element: AXUIElement) {
        self.element = element
    }
    
    var selectedText: String {
        get {
            var selectedTextRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedTextRef)
            guard let selectedText = selectedTextRef as? String, result == .success else {
                Log.info("No selected text: \(result)")
                return ""
            }
            return selectedText
        }
        set {
            var isSettable = DarwinBoolean(false)
            AXUIElementIsAttributeSettable(element, kAXSelectedTextAttribute as CFString, &isSettable)
            Log.info("IsSettable: \(isSettable)")

            if isSettable.boolValue {
                let result = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, newValue as CFString)
                Log.info("Result: \(result)")
            }
        }
    }
}
