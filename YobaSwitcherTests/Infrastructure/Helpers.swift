//
//  Created by Vladislav Librecht on 21.07.2026
//

@testable import YobaSwitcher
import CoreGraphics
import Carbon

extension CGEvent {
    enum Direction {
        case up, down
    }
    
    static func key(_ direction: Direction, _ keyCode: Int, _ flags: CGEventFlags = []) -> CGEvent {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: direction == .down)!
        event.flags = flags
        event.flags.insert(.maskNonCoalesced)
        return event
    }
    
    static func flagsChanged(_ keyCode: Int, _ flags: CGEventFlags = []) -> CGEvent {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)!
        event.flags = flags
        event.flags.insert(.maskNonCoalesced)
        return event
    }
    
    static var mouseDown: CGEvent {
        CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: .zero, mouseButton: .left)!
    }
}

extension InputEvent {
    init(_ cgEvent: CGEvent) {
        switch cgEvent.type {
        case .flagsChanged:
            self = .flagsChanged(Keystroke(event: cgEvent))
        case .keyDown:
            self = .key(.down, Keystroke(event: cgEvent))
        case .keyUp:
            self = .key(.up, Keystroke(event: cgEvent))
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            self = .mouseDown
        default:
            fatalError("Unknown CGEvent type")
        }
    }
    
    static func key(_ direction: Direction, _ rawKeyCode: Int, _ flags: CGEventFlags = []) -> InputEvent {
        .key(direction, Keystroke(keyCode: rawKeyCode, flags: flags))
    }
    
    static func flagsChanged(_ rawKeyCode: Int, _ flags: CGEventFlags = []) -> InputEvent {
        .flagsChanged(Keystroke(keyCode: rawKeyCode, flags: flags))
    }
}

func * <C>(lhs: C, rhs: Int) -> [C.Element] where C: Sequence {
    var result: [C.Element] = []
    for _ in 0..<rhs {
        result.append(contentsOf: lhs)
    }
    return result
}

final class EventTapProxyStub {}
