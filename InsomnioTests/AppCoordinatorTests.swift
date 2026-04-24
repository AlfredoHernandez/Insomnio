//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppKit
import Automation
import Insomniac
import InsomniacTesting
import Testing
import TimerSchedulerTesting

struct AppCoordinatorTests {
	@Test
	func `Start registers shortcut`() {
		let (sut, spies) = makeSUT()

		sut.start()

		#expect(spies.shortcut.receivedMessages == [.registerShortcut])
	}

	@Test
	func `Start calls automation startMonitoring`() {
		let (sut, spies) = makeSUT()

		sut.start()

		#expect(spies.automation.receivedMessages == [.startMonitoring])
	}

	@Test
	func `Start loads products via premium manager`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		await sut.bootstrapTask?.value

		#expect(spies.premium.receivedMessages.contains(.loadProducts))
	}

	@Test
	func `Start is idempotent and does not re-register on second call`() {
		let (sut, spies) = makeSUT()

		sut.start()
		sut.start()

		#expect(spies.shortcut.receivedMessages == [.registerShortcut])
		#expect(spies.automation.receivedMessages == [.startMonitoring])
	}

	@Test
	func `Shortcut action toggles insomniac`() {
		let (sut, spies) = makeSUT()

		sut.start()
		spies.shortcut.registeredAction?()

		#expect(spies.insomniac.isActive == true)
	}

	@Test
	func `willTerminate notification stops automation and insomniac`() {
		let (sut, spies) = makeSUT()
		sut.start()
		spies.insomniac.start()
		#expect(spies.insomniac.isActive == true)

		// `AppCoordinator` installs the observer with `queue: nil`, so posting
		// from the main actor runs the handler synchronously before this
		// `post(_:)` call returns — no awaiting required.
		NotificationCenter.default.post(name: NSApplication.willTerminateNotification, object: nil)

		#expect(spies.automation.receivedMessages.contains(.stopMonitoring))
		#expect(spies.insomniac.isActive == false)
	}

	// MARK: - Helpers

	private struct Spies {
		let insomniac: Insomniac
		let premium: PremiumManagerSpy
		let automation: AutomationCoordinatingSpy
		let shortcut: GlobalShortcutManagerSpy
	}

	private func makeSUT() -> (AppCoordinator, Spies) {
		let insomniac = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
			timerScheduler: TimerSchedulerSpy(),
		)
		let premium = PremiumManagerSpy()
		let automation = AutomationCoordinatingSpy()
		let shortcut = GlobalShortcutManagerSpy()
		let dependencies = AppDependencies(
			insomniac: insomniac,
			premiumManager: premium,
			scheduleEvaluator: ScheduleEvaluatorPreviewStub(),
			appRulesEvaluator: AppRulesEvaluatorPreviewStub(),
			automationCoordinator: automation,
			shortcutManager: shortcut,
			launchAtLoginManager: LaunchAtLoginManagerPreviewStub(),
			accessibilityPermissionChecker: AccessibilityPermissionCheckerPreviewStub(),
			availableApps: { [] },
		)
		let sut = AppCoordinator(dependencies: dependencies)
		let spies = Spies(insomniac: insomniac, premium: premium, automation: automation, shortcut: shortcut)
		return (sut, spies)
	}
}
