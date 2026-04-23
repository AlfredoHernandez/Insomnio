//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

public protocol AccessibilityPermissionChecker {
	var isGranted: Bool { get }
	func promptForPermission()
}
