//
//  DistributedNotificationCenter.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 13.01.2023.
//

import Carbon
import CoreFoundation

/// Wrapper around Core Foundation distributed notifications center
final class DistributedNotificationCenter {
    typealias Callback = (Token, CFDictionary?) -> Void
    
    final class Token {
        fileprivate var callback: Callback?
        
        fileprivate init(callback: Callback?) {
            self.callback = callback
        }
        
        deinit {
            Log.trace(self)
        }
    }
    
    static let `default` = DistributedNotificationCenter()
    
    func addObserver(forName name: CFNotificationName, suspensionBehavior: CFNotificationSuspensionBehavior, using block: @escaping Callback) -> Token {
        let token = Token(callback: block)
        let observer = UnsafeRawPointer(Unmanaged.passRetained(token).toOpaque()) // +1 retain token here
        
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDistributedCenter(),
            observer,
            { center, observer, _, _, userInfo in
                if let observer = observer {
                    let token = Unmanaged<Token>.fromOpaque(observer).takeUnretainedValue()
                    token.callback?(token, userInfo)
                } else {
                    Log.critical("CFNotificationCallback was called with nil observer")
                }
            },
            name.rawValue,
            nil,
            suspensionBehavior
        )
        
        return token
    }
    
    func removeObserver(_ token: AnyObject, name: CFNotificationName) {
        let unmanaged = Unmanaged.passUnretained(token)
        unmanaged.release() // -1 retain token here
        let observer = UnsafeRawPointer(unmanaged.toOpaque())
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(), observer, name, nil)
    }
}

extension CFNotificationName {
    static let selectedKeyboardInputSourceChanged = CFNotificationName(kTISNotifySelectedKeyboardInputSourceChanged)
}
