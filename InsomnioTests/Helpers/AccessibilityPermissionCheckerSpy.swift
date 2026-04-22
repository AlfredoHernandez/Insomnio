//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class AccessibilityPermissionCheckerSpy: AccessibilityPermissionChecker {
	var isGranted: Bool
	private(set) var promptCount = 0

	init(isGranted: Bool = false) {
		self.isGranted = isGranted
	}

	func promptForPermission() {
		promptCount += 1
	}
}
