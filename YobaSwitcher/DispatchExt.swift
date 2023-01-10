//
//  DispatchExt.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import Foundation

protocol DispatchQueueProtocol {
    func asyncAfter(timeInterval: DispatchTimeInterval, execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueProtocol {
    func asyncAfter(timeInterval: DispatchTimeInterval, execute work: @escaping () -> Void) {
        asyncAfter(deadline: .now() + timeInterval, execute: work)
    }
}
