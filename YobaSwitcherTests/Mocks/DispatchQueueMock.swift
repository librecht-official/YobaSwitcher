//
//  DispatchQueueMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class DispatchQueueMock: DispatchQueueProtocol {
    var executesWorkImmediately: Bool = true
    
    func asyncAfter(timeInterval: DispatchTimeInterval, execute work: @escaping () -> Void) {
        if executesWorkImmediately {
            work()
        }
    }
}
