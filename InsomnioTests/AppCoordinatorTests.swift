//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppKit
import AppRulesTesting
import Automation
import Insomniac
import InsomniacTesting
import ScheduleTesting
import Testing
import TestSupport
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

	// MARK: - Memory Leak Tracking

	@Test
	func `AppCoordinator does not leak after start and termination`() {
		assertNoLeaks {
			let (sut, spies) = makeSUT()
			sut.start()
			NotificationCenter.default.post(name: NSApplication.willTerminateNotification, object: nil)
			// Clear the process-global App Intents performer set by `start()` so
			// the SUT's `Insomniac` is not retained beyond this test scope.
			IntentDependencies.performer = nil
			return [sut, spies.insomniac, spies.automation, spies.shortcut]
		}
	}

	// MARK: - Helpers

	private struct Spies {
		let insomniac: Insomniac
		let automation: AutomationCoordinatingSpy
		let shortcut: GlobalShortcutManagerSpy
	}

	private func makeSUT() -> (AppCoordinator, Spies) {
		// Reset the process-global App Intents performer so a previous test's
		// `Insomniac` is not retained across tests via the static reference.
		IntentDependencies.performer = nil
		let insomniac = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
			timerScheduler: TimerSchedulerSpy(),
		)
		let automation = AutomationCoordinatingSpy()
		let shortcut = GlobalShortcutManagerSpy()
		let dependencies = AppDependencies(
			insomniac: insomniac,
			scheduleEvaluator: ScheduleEvaluatorSpy(),
			appRulesEvaluator: AppRulesEvaluatorSpy(),
			automationCoordinator: automation,
			shortcutManager: shortcut,
			launchAtLoginManager: LaunchAtLoginManagerPreviewStub(),
			accessibilityPermissionChecker: AccessibilityPermissionCheckerPreviewStub(),
			availableApps: { [] },
		)
		let sut = AppCoordinator(dependencies: dependencies)
		let spies = Spies(insomniac: insomniac, automation: automation, shortcut: shortcut)
		return (sut, spies)
	}
}
