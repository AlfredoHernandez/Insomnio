//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import AutoUpdate

final class UpdateControllerPreviewStub: UpdateController {
	var automaticallyChecksForUpdates: Bool = true
	var canCheckForUpdates: Bool = true
	func checkForUpdates() {}
}
#endif
