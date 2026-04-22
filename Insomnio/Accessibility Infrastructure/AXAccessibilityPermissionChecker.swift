//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import ApplicationServices

final class AXAccessibilityPermissionChecker: AccessibilityPermissionChecker {
	private static let privacyAccessibilityURL = URL(
		string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
	)!

	var isGranted: Bool {
		AXIsProcessTrusted()
	}

	func promptForPermission() {
		let promptKey = "AXTrustedCheckOptionPrompt"
		_ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
		NSWorkspace.shared.open(Self.privacyAccessibilityURL)
	}
}
