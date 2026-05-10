//
//  DistributedNotificationCenter.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import Carbon
import Foundation

// sourcery: AutoMockable
protocol DistributedNotificationCenterProtocol {
    func addObserver(
        _ observer: Any,
        selector: Selector,
        name: NSNotification.Name?,
        object: String?,
        suspensionBehavior: DistributedNotificationCenter.SuspensionBehavior
    )
    
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: String?)
}

extension DistributedNotificationCenter: DistributedNotificationCenterProtocol {}

extension NSNotification.Name {
    static let selectedKeyboardInputSourceChanged = NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String)
}
