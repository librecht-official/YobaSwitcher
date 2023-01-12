//
//  CallCount.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 13.01.2023.
//

struct CallCount: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int

    let value: Int

    init(integerLiteral value: Int) {
        self.value = value
    }
    
    static let once = CallCount(integerLiteral: 1)
    
    static let twice = CallCount(integerLiteral: 2)
}
