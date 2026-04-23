//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import AccessibilityPermission

final class AccessibilityPermissionCheckerPreviewStub: AccessibilityPermissionChecker {
	var isGranted: Bool

	init(isGranted: Bool = true) {
		self.isGranted = isGranted
	}

	func promptForPermission() {}
}
#endif
