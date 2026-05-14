//
//  Created by Vladislav Librecht on 14.05.2026
//

func build<O: AnyObject>(_ object: O, _ builder: (O) -> Void) -> O {
    builder(object)
    return object
}
