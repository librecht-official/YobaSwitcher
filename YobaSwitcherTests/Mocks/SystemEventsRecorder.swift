//
//  Created by Vladislav Librecht on 14.05.2026
//

import CoreGraphics
@testable import YobaSwitcher

final class SystemEventsRecorder: SystemEventsAPI {
    var recordedEvents: [InputEvent] = []
    var pasteboard: PasteboardMock?
    
    func postEvent(_ inputEvent: InputEvent, _ proxy: CGEventTapProxy) {
        recordedEvents.append(inputEvent)
    }
    
    func postEvent(_ inputEvent: InputEvent, at location: CGEventTapLocation) {
        recordedEvents.append(inputEvent)
        
        // On Cmd+C emulate copying selectedText to pasteboard
        if let pasteboard {
            let isCmdC = recordedEvents.suffix(2).matches([
                .keyUp(Keystroke(.c, flags: .maskCommand)),
                .flagsChanged(Keystroke(.command, flags: []), keyDown: false),
            ])
            if isCmdC, let selectedText = pasteboard._selectedText {
                pasteboard.setString(selectedText, forType: .string)
            }
        }
    }
}
