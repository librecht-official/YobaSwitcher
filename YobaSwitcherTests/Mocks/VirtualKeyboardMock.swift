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
    
    // MARK: postKeyDown(_ keyCode: Int, _ proxy: CGEventTapProxy)
    
    lazy var _postKeyDown = MethodStub<(Int, CGEventTapProxy), Void>(name: "postKeyDown(_ keyCode: Int, _ proxy: CGEventTapProxy)", testCase)
    
    func postKeyDown(_ keyCode: Int, _ proxy: CGEventTapProxy) {
        _postKeyDown.call(with: (keyCode, proxy))
    }
    
    // MARK: postKeyUp(_ keyCode: Int, _ proxy: CGEventTapProxy)
    
    lazy var _postKeyUp = MethodStub<(Int, CGEventTapProxy), Void>(name: "postKeyUp(_ keyCode: Int, _ proxy: CGEventTapProxy)", testCase)
    
    func postKeyUp(_ keyCode: Int, _ proxy: CGEventTapProxy) {
        _postKeyUp.call(with: (keyCode, proxy))
    }
    
    // MARK: switchInputSource()
    
    lazy var _switchInputSource = MethodStub<Void, Void>(name: "switchInputSource()", testCase)
    
    func switchInputSource() {
        _switchInputSource.call(with: ())
    }
}
