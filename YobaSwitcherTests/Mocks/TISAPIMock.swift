//
//  Created by Vladislav Librecht on 14.05.2026
//

import Cocoa
import Carbon
@testable import YobaSwitcher

final class TISRefMock: TextInputSourceReference {
    let id: String
    var isSelected: Bool
    weak var tisAPI: TISAPIMock?
    
    init(id: String = "en", isSelected: Bool = false, tisAPI: TISAPIMock?) {
        self.id = id
        self.isSelected = isSelected
        self.tisAPI = tisAPI
    }
    
    func value<T>(key: CFString) -> T? {
        switch key {
        case kTISPropertyInputSourceID:
            return id as? T
        case kTISPropertyInputSourceIsSelected:
            return isSelected as? T
        default:
            return nil
        }
    }
    
    func select() {
        tisAPI?.select(TextInputSource(self))
        isSelected = true
    }
    
    static func == (lhs: TISRefMock, rhs: TISRefMock) -> Bool {
        lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}

final class TISAPIMock: TextInputSourceAPI, DistributedNotificationCenterProtocol {
    var data: [TISRefMock] = []
    var observer: Any?, selector: Selector?
    
    init() {
        self.data = [
            TISRefMock(id: "en", isSelected: true, tisAPI: self),
            TISRefMock(id: "ru", isSelected: false, tisAPI: self),
        ]
    }
    
    func currentKeyboardLayoutInputSource() -> TextInputSource {
        let tisRef = data.first(where: \.isSelected)!
        return TextInputSource(tisRef)
    }
    
    func inputSource(forLanguage id: String) -> TextInputSource {
        let tisRef = data.first(where: { $0.id == id })!
        return TextInputSource(tisRef)
    }
    
    func inputSourceList(filter: [CFString : Any]) -> [TextInputSource] {
        data.map { TextInputSource($0) }
    }
    
    func select(_ source: TextInputSource) {
        data.forEach {
            if $0.id != source.id {
                $0.isSelected = false
            }
        }
        guard let observer = observer as? AnyObject, let selector else {
            assertionFailure("No observer and selector")
            return
        }
        _ = observer.perform(selector, with: "test-notification")
    }
    
    func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name?, object: String?, suspensionBehavior: DistributedNotificationCenter.SuspensionBehavior) {
        self.observer = observer
        self.selector = selector
    }
    
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: String?) {
        
    }
}
