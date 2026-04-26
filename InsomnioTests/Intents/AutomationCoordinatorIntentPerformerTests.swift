//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AutoStop
import AutoStopTesting
import Insomniac
import InsomniacTesting
import Testing
import TimerSchedulerTesting

struct AutomationCoordinatorIntentPerformerTests {
	@Test
	func `Start activates the insomniac model`() {
		let (sut, insomniac) = makeSUT()

		sut.start()

		#expect(insomniac.isActive == true)
		#expect(insomniac.activationSource == .shortcutsIntent)
	}

	@Test
	func `Start is idempotent on an already active model`() {
		let (sut, insomniac) = makeSUT()
		insomniac.start()

		sut.start()

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Stop deactivates the insomniac model`() {
		let (sut, insomniac) = makeSUT()
		insomniac.start()

		sut.stop()

		#expect(insomniac.isActive == false)
	}

	@Test
	func `Stop is idempotent on an already inactive model`() {
		let (sut, insomniac) = makeSUT()

		sut.stop()

		#expect(insomniac.isActive == false)
	}

	@Test
	func `Toggle activates an idle insomniac`() {
		let (sut, insomniac) = makeSUT()

		sut.toggle()

		#expect(insomniac.isActive == true)
	}

	@Test
	func `Toggle deactivates an active insomniac`() {
		let (sut, insomniac) = makeSUT()
		insomniac.start()

		sut.toggle()

		#expect(insomniac.isActive == false)
	}

	@Test(arguments: [AutoStopDuration.thirtyMinutes, .oneHour, .twoHours, .fourHours] as [AutoStopDuration])
	func `Start for duration enables auto-stop, sets duration and activates the model`(
		_ duration: AutoStopDuration,
	) {
		let (sut, insomniac) = makeSUT()

		sut.startForDuration(duration)

		#expect(insomniac.autoStopEnabled == true)
		#expect(insomniac.autoStopDuration == duration)
		#expect(insomniac.isActive == true)
	}

	@Test
	func `Start for duration on an already active model restarts the auto-stop timer with the new duration`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, insomniac) = makeSUT(autoStopTimer: autoStopTimer)
		insomniac.autoStopEnabled = true
		insomniac.autoStopDuration = .oneHour
		insomniac.start()

		sut.startForDuration(.fourHours)

		#expect(insomniac.autoStopEnabled == true)
		#expect(insomniac.autoStopDuration == .fourHours)
		#expect(insomniac.isActive == true)
		#expect(autoStopTimer.receivedMessages == [
			.start(AutoStopDuration.oneHour.seconds),
			.cancel,
			.start(AutoStopDuration.fourHours.seconds),
		])
	}

	// MARK: - Helpers

	private func makeSUT(
		autoStopTimer: (any AutoStopTimer)? = nil,
	) -> (AutomationCoordinatorIntentPerformer, Insomniac) {
		let insomniac = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
			autoStopTimer: autoStopTimer,
			timerScheduler: TimerSchedulerSpy(),
		)
		let sut = AutomationCoordinatorIntentPerformer(insomniac: insomniac)
		return (sut, insomniac)
	}
}
