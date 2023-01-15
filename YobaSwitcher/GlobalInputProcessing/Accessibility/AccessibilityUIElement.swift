//
//  AccessibilityUIElement.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 15.01.2023.
//

import ApplicationServices

// sourcery: AutoMockable
protocol AccessibilityUIElement {
    static var systemWide: AccessibilityUIElement { get }
    
    @discardableResult
    func copyAttributeValue(_ attribute: String, _ value: UnsafeMutablePointer<CFTypeRef?>) -> AXError
    
    @discardableResult
    func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError
    
    @discardableResult
    func setAttributeValue(_ attribute: String, _ value: CFTypeRef) -> AXError
}

extension AXUIElement: AccessibilityUIElement {
    static var systemWide: AccessibilityUIElement {
        AXUIElementCreateSystemWide()
    }
    
    @discardableResult
    func copyAttributeValue(_ attribute: String, _ value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
        AXUIElementCopyAttributeValue(self, attribute as CFString, value)
    }
    
    @discardableResult
    func isAttributeSettable(_ attribute: String, _ settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError {
        AXUIElementIsAttributeSettable(self, attribute as CFString, settable)
    }
    
    @discardableResult
    func setAttributeValue(_ attribute: String, _ value: CFTypeRef) -> AXError {
        AXUIElementSetAttributeValue(self, attribute as CFString, value)
    }
}
