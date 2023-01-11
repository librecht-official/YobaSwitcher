//
//  VirtualKeyboardMock.swift
//  YobaSwitcherTests
//
//  Created by Vladislav Librecht on 11.01.2023.
//

import XCTest
@testable import YobaSwitcher

final class VirtualKeyboardMock: VirtualKeyboardProtocol {
    
    private(set) weak var testCase: XCTestCase?
    
    init(_ testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    lazy var _postKeystrokeEvent = MethodStub<(KeystrokeEvent, CGEventTapProxy), Void>(name: "postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy)", testCase)
    
    func postKeystrokeEvent(_ keystrokeEvent: KeystrokeEvent, _ proxy: CGEventTapProxy) {
        _postKeystrokeEvent.call(with: (keystrokeEvent, proxy))
    }
    
    // MARK: switchInputSource()
    
    lazy var _switchInputSource = MethodStub<Void, Void>(name: "switchInputSource()", testCase)
    
    func switchInputSource() {
        _switchInputSource.call(with: ())
    }
}
