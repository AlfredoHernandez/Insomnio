//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppKit
import Testing

@MainActor
struct AppCoordinatorTests {
	@Test
	func `Start registers shortcut`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		await Task.yield()

		#expect(spies.shortcut.receivedMessages == [.registerShortcut])
	}

	@Test
	func `Start calls automation startMonitoring`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		await Task.yield()

		#expect(spies.automation.receivedMessages == [.startMonitoring])
	}

	@Test
	func `Start loads products via premium manager`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		await waitUntil { spies.premium.receivedMessages.contains(.loadProducts) }

		#expect(spies.premium.receivedMessages.contains(.loadProducts))
	}

	@Test
	func `Start is idempotent and does not re-register on second call`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		sut.start()
		await Task.yield()

		#expect(spies.shortcut.receivedMessages == [.registerShortcut])
		#expect(spies.automation.receivedMessages == [.startMonitoring])
	}

	@Test
	func `Shortcut action toggles insomniac`() async {
		let (sut, spies) = makeSUT()

		sut.start()
		await Task.yield()
		spies.shortcut.registeredAction?()

		#expect(spies.insomniac.isActive == true)
	}

	@Test
	func `willTerminate notification stops automation and insomniac`() async {
		let (sut, spies) = makeSUT()
		sut.start()
		await Task.yield()
		spies.insomniac.start()
		#expect(spies.insomniac.isActive == true)

		NotificationCenter.default.post(name: NSApplication.willTerminateNotification, object: nil)
		await waitUntil { spies.automation.receivedMessages.contains(.stopMonitoring) }

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

	private func waitUntil(
		timeout: Duration = .seconds(1),
		_ condition: () -> Bool,
	) async {
		let start = ContinuousClock.now
		while !condition(), ContinuousClock.now - start < timeout {
			await Task.yield()
			try? await Task.sleep(for: .milliseconds(10))
		}
	}
}
