//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AccessibilityPermission
import SwiftUI
import Testing

@MainActor
struct AccessibilityPermissionBannerTests {
	@Test
	func `Banner hides when permission is granted at init`() {
		let spy = AccessibilityPermissionCheckerSpy(isGranted: true)

		let sut = AccessibilityPermissionBanner(checker: spy)

		#expect(sut.isShowingBannerForTesting == false)
	}

	@Test
	func `Banner shows when permission is denied at init`() {
		let spy = AccessibilityPermissionCheckerSpy(isGranted: false)

		let sut = AccessibilityPermissionBanner(checker: spy)

		#expect(sut.isShowingBannerForTesting == true)
	}

	@Test
	func `Prompt button invokes checker promptForPermission`() {
		let spy = AccessibilityPermissionCheckerSpy(isGranted: false)
		let sut = AccessibilityPermissionBanner(checker: spy)

		sut.invokePromptForTesting()

		#expect(spy.promptCount == 1)
	}
}
