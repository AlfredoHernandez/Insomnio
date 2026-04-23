//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AccessibilityPermission
import SwiftUI

struct AccessibilityPermissionBanner: View {
	let checker: any AccessibilityPermissionChecker
	@State private var isGranted: Bool

	init(checker: any AccessibilityPermissionChecker) {
		self.checker = checker
		_isGranted = State(initialValue: checker.isGranted)
	}

	var body: some View {
		Group {
			if !isGranted {
				CardView {
					VStack(alignment: .leading, spacing: 8) {
						HStack(spacing: 8) {
							Image(systemName: "exclamationmark.triangle.fill")
								.foregroundStyle(.yellow)
							Text("accessibility_banner_title")
								.font(.headline)
						}
						Text("accessibility_banner_message")
							.font(.callout)
							.foregroundStyle(.secondary)
							.fixedSize(horizontal: false, vertical: true)
						Button {
							checker.promptForPermission()
						} label: {
							Text("accessibility_banner_button")
						}
						.controlSize(.small)
					}
				}
				.accessibilityIdentifier("accessibility_permission_banner")
			}
		}
		.onAppear { isGranted = checker.isGranted }
	}
}

#if DEBUG
extension AccessibilityPermissionBanner {
	var isShowingBannerForTesting: Bool {
		!isGranted
	}

	func invokePromptForTesting() {
		checker.promptForPermission()
	}
}
#endif
