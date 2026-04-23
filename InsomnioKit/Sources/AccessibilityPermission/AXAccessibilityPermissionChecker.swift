//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import ApplicationServices

public final class AXAccessibilityPermissionChecker: AccessibilityPermissionChecker {
	private static let privacyAccessibilityURL = URL(
		string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
	)!

	public init() {}

	public var isGranted: Bool {
		AXIsProcessTrusted()
	}

	public func promptForPermission() {
		let promptKey = "AXTrustedCheckOptionPrompt"
		_ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
		NSWorkspace.shared.open(Self.privacyAccessibilityURL)
	}
}
