//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol AccessibilityPermissionChecker {
	var isGranted: Bool { get }
	func promptForPermission()
}
