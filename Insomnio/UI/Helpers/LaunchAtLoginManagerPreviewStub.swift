//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import LaunchAtLogin

final class LaunchAtLoginManagerPreviewStub: LaunchAtLoginManager {
	var isEnabled = false
	func enable() throws {}
	func disable() throws {}
}
#endif
