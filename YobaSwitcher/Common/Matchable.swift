//
//  Matchable.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 14.01.2023.
//

/// A type that can be compared with some pattern for matching.
protocol Matchable {
    associatedtype Pattern
    
    func matches(_ rhs: Pattern) -> Bool
}

extension Collection where Element: Matchable {
    func matches(_ rhs: [Element.Pattern]) -> Bool {
        guard count == rhs.count else { return false }
        return zip(self, rhs).allSatisfy { $0.matches($1) }
    }
}

extension Optional where Wrapped: Matchable {
    func matches(_ rhs: Wrapped.Pattern) -> Bool {
        switch self {
        case .none:
            return false
        case let .some(wrapped):
            return wrapped.matches(rhs)
        }
    }
}
