//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

@MainActor
@Suite("Insomniac")
struct InsomniacTests {
	@Test("Init does not message mouse mover upon creation")
	func init_doesNotMessageMouseMoverUponCreation() {
		let (_, mover, _) = makeSUT()

		#expect(mover.receivedMessages == [])
	}

	@Test("Init does not message sleep preventer upon creation")
	func init_doesNotMessageSleepPreventerUponCreation() {
		let (_, _, sleepPreventer) = makeSUT()

		#expect(sleepPreventer.receivedMessages == [])
	}

	@Test("Init is not active")
	func init_isNotActive() {
		let (sut, _, _) = makeSUT()

		#expect(sut.isActive == false)
	}

	@Test("Init default interval is 30 seconds")
	func init_defaultIntervalIs30Seconds() {
		let (sut, _, _) = makeSUT()

		#expect(sut.interval == 30.0)
	}

	@Test("Init default mode is moveCursor")
	func init_defaultModeIsMoveCursor() {
		let (sut, _, _) = makeSUT()

		#expect(sut.mode == .moveCursor)
	}

	@Test("Init activation count is zero")
	func init_activationCountIsZero() {
		let (sut, _, _) = makeSUT()

		#expect(sut.activationCount == 0)
	}

	@Test("Init last activation is nil")
	func init_lastActivationIsNil() {
		let (sut, _, _) = makeSUT()

		#expect(sut.lastActivation == nil)
	}

	@Test("Start sets isActive to true")
	func start_setsIsActiveToTrue() {
		let (sut, _, _) = makeSUT()

		sut.start()

		#expect(sut.isActive == true)
	}

	@Test("Start creates assertion in preventSleep mode")
	func start_createsAssertionInPreventSleepMode() {
		let (sut, _, sleepPreventer) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	@Test("Start increments activation count in preventSleep mode")
	func start_incrementsActivationCountInPreventSleepMode() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.activationCount == 1)
	}

	@Test("Start sets last activation in preventSleep mode")
	func start_setsLastActivationInPreventSleepMode() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.lastActivation != nil)
	}

	@Test("Start does not start twice")
	func start_doesNotStartTwice() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(timerScheduler: timerScheduler)

		sut.start()
		sut.start()

		#expect(sut.isActive == true)
		let scheduleCount = timerScheduler.receivedMessages.count(where: {
			if case .schedule = $0 { return true }; return false
		})
		#expect(scheduleCount == 1)
	}

	@Test("Stop sets isActive to false")
	func stop_setsIsActiveToFalse() {
		let (sut, _, _) = makeSUT()

		sut.start()
		sut.stop()

		#expect(sut.isActive == false)
	}

	@Test("Stop releases assertion")
	func stop_releasesAssertion() {
		let (sut, _, sleepPreventer) = makeSUT()

		sut.start()
		sut.stop()

		#expect(sleepPreventer.receivedMessages == [.releaseAssertion])
	}

	@Test("Stop releases assertion in preventSleep mode")
	func stop_releasesAssertionInPreventSleepMode() {
		let (sut, _, sleepPreventer) = makeSUT()
		sut.mode = .preventSleep

		sut.start()
		sut.stop()

		#expect(sleepPreventer.receivedMessages == [.createAssertion, .releaseAssertion])
	}

	@Test("Toggle starts when inactive")
	func toggle_startsWhenInactive() {
		let (sut, _, _) = makeSUT()

		sut.toggle()

		#expect(sut.isActive == true)
	}

	@Test("Toggle stops when active")
	func toggle_stopsWhenActive() {
		let (sut, _, _) = makeSUT()

		sut.start()
		sut.toggle()

		#expect(sut.isActive == false)
	}

	@Test("keepAwake moves cursor right then back to original")
	func keepAwake_movesCursorRightThenBackToOriginal() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test("keepAwake increments activation count")
	func keepAwake_incrementsActivationCount() {
		let (sut, _, _) = makeSUT()

		sut.keepAwake()
		sut.keepAwake()

		#expect(sut.activationCount == 2)
	}

	@Test("keepAwake sets last activation")
	func keepAwake_setsLastActivation() {
		let (sut, _, _) = makeSUT()

		sut.keepAwake()

		#expect(sut.lastActivation != nil)
	}

	// MARK: - Idle Feature Tests

	@Test("Init onlyWhenIdle defaults to false")
	func init_onlyWhenIdleDefaultsToFalse() {
		let (sut, _, _) = makeSUT()

		#expect(sut.onlyWhenIdle == false)
	}

	@Test("keepAwake when onlyWhenIdle and user active does not move cursor")
	func keepAwake_whenOnlyWhenIdleAndUserActive_doesNotMoveCursor() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, mover, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 2.0

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test("keepAwake when onlyWhenIdle and user idle moves cursor")
	func keepAwake_whenOnlyWhenIdleAndUserIdle_movesCursor() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, mover, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 10.0
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test("keepAwake when onlyWhenIdle disabled always moves")
	func keepAwake_whenOnlyWhenIdleDisabled_alwaysMoves() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, mover, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = false
		idleTimeProvider.stubbedIdleTime = 0
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test("keepAwake when onlyWhenIdle and user active does not increment count")
	func keepAwake_whenOnlyWhenIdleAndUserActive_doesNotIncrementCount() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, _, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 2.0

		sut.keepAwake()

		#expect(sut.activationCount == 0)
	}

	// MARK: - Battery Feature Tests

	@Test("Init pauseOnBattery defaults to false")
	func init_pauseOnBatteryDefaultsToFalse() {
		let (sut, _, _) = makeSUT()

		#expect(sut.pauseOnBattery == false)
	}

	@Test("keepAwake when pauseOnBattery and on battery does not move cursor")
	func keepAwake_whenPauseOnBatteryAndOnBattery_doesNotMoveCursor() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, mover, _) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test("keepAwake when pauseOnBattery and on AC moves cursor")
	func keepAwake_whenPauseOnBatteryAndOnAC_movesCursor() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, mover, _) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = false
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test("keepAwake when pauseOnBattery disabled always moves")
	func keepAwake_whenPauseOnBatteryDisabled_alwaysMoves() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, mover, _) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.pauseOnBattery = false
		powerSourceProvider.stubbedIsOnBattery = true
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test("Start preventSleep with pauseOnBattery and on battery does not create assertion")
	func start_preventSleepAndPauseOnBatteryAndOnBattery_doesNotCreateAssertion() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, _, sleepPreventer) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.start()

		#expect(!sleepPreventer.receivedMessages.contains(.createAssertion))
	}

	@Test("Start preventSleep with pauseOnBattery and on AC creates assertion")
	func start_preventSleepAndPauseOnBatteryAndOnAC_createsAssertion() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, _, sleepPreventer) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = false

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	// MARK: - Cursor Pattern Tests

	@Test("Init default cursor pattern is nudge")
	func init_defaultCursorPatternIsNudge() {
		let (sut, _, _) = makeSUT()

		#expect(sut.cursorPattern == .nudge)
	}

	@Test("keepAwake with circle pattern moves cursor through circle points then back")
	func keepAwake_withCirclePattern_movesCursorThroughCirclePointsThenBack() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 100, y: 100)
		sut.cursorPattern = .circle

		sut.keepAwake()

		let messages = mover.receivedMessages
		#expect(messages.first == .currentLocation)
		#expect(messages.last == .moveTo(CGPoint(x: 100, y: 100)))
		// 1 currentLocation + 8 circle points + 1 return = 10 messages
		#expect(messages.count == 10)
	}

	@Test("keepAwake with zigzag pattern moves cursor through zigzag points then back")
	func keepAwake_withZigzagPattern_movesCursorThroughZigzagPointsThenBack() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 50, y: 50)
		sut.cursorPattern = .zigzag

		sut.keepAwake()

		let messages = mover.receivedMessages
		#expect(messages.first == .currentLocation)
		#expect(messages.last == .moveTo(CGPoint(x: 50, y: 50)))
		// 1 currentLocation + 4 zigzag points + 1 return = 6 messages
		#expect(messages.count == 6)
	}

	// MARK: - Auto-Stop Tests

	@Test("Init autoStopEnabled defaults to false")
	func init_autoStopEnabledDefaultsToFalse() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopEnabled == false)
	}

	@Test("Init autoStopDuration defaults to one hour")
	func init_autoStopDurationDefaultsToOneHour() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopDuration == .oneHour)
	}

	@Test("Start with autoStop enabled starts auto-stop timer")
	func start_withAutoStopEnabled_startsAutoStopTimer() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true
		sut.autoStopDuration = .twoHours

		sut.start()

		#expect(autoStopTimer.receivedMessages == [.start(7200)])
	}

	@Test("Start with autoStop disabled does not start auto-stop timer")
	func start_withAutoStopDisabled_doesNotStartAutoStopTimer() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = false

		sut.start()

		#expect(autoStopTimer.receivedMessages == [])
	}

	@Test("Stop cancels auto-stop timer")
	func stop_cancelsAutoStopTimer() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()
		sut.stop()

		#expect(autoStopTimer.receivedMessages == [.start(3600), .cancel])
	}

	@Test("Auto-stop timer expiration stops insomniac")
	func autoStopTimerExpiration_stopsInsomniac() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()
		#expect(sut.isActive == true)

		autoStopTimer.simulateExpiration()

		#expect(sut.isActive == false)
	}

	@Test("autoStopRemainingTime delegates to timer")
	func autoStopRemainingTime_delegatesToTimer() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopRemainingTime == autoStopTimer.remainingTime)
	}

	@Test("autoStopIsRunning delegates to timer")
	func autoStopIsRunning_delegatesToTimer() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopIsRunning == autoStopTimer.isRunning)
	}

	@Test("autoStopRemainingTime returns zero when no timer")
	func autoStopRemainingTime_returnsZeroWhenNoTimer() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopRemainingTime == 0)
	}

	@Test("autoStopIsRunning returns false when no timer")
	func autoStopIsRunning_returnsFalseWhenNoTimer() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopIsRunning == false)
	}

	// MARK: - Timer Scheduler Tests

	@Test("Start in moveCursor mode schedules timer with configured interval")
	func start_moveCursor_schedulesTimerWithConfiguredInterval() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(timerScheduler: timerScheduler)
		sut.interval = 45

		sut.start()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 45)])
	}

	@Test("Start in moveCursor mode timer fire calls keepAwake")
	func start_moveCursor_timerFireCallsKeepAwake() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, mover, _) = makeSUT(timerScheduler: timerScheduler)
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.start()
		timerScheduler.fire(at: 0)

		#expect(mover.receivedMessages.contains(.currentLocation))
	}

	@Test("Stop invalidates scheduled timer")
	func stop_invalidatesScheduledTimer() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(timerScheduler: timerScheduler)

		sut.start()
		sut.stop()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	@Test("Start in preventSleep with pauseOnBattery schedules power check timer")
	func start_preventSleep_pauseOnBattery_schedulesPowerCheckTimer() {
		let powerSourceProvider = PowerSourceProviderSpy()
		powerSourceProvider.stubbedIsOnBattery = false
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(powerSourceProvider: powerSourceProvider, timerScheduler: timerScheduler)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true

		sut.start()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 30)])
	}

	// MARK: - Memory Leak Tracking

	@Test("makeSUT does not leak after start and stop")
	func makeSUT_doesNotLeakAfterStartAndStop() {
		assertNoLeaks {
			let (sut, mover, sleepPreventer) = makeSUT()
			sut.start()
			sut.stop()
			return [sut, mover, sleepPreventer]
		}
	}

	// MARK: - Helpers

	private func makeSUT(
		idleTimeProvider: IdleTimeProviderSpy? = nil,
		powerSourceProvider: PowerSourceProviderSpy? = nil,
		autoStopTimer: AutoStopTimerSpy? = nil,
		timerScheduler: TimerSchedulerSpy? = nil,
	) -> (sut: Insomniac, mover: MouseMoverSpy, sleepPreventer: SleepPreventerSpy) {
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let sut = Insomniac(
			mouseMover: mover,
			sleepPreventer: sleepPreventer,
			idleTimeProvider: idleTimeProvider,
			powerSourceProvider: powerSourceProvider,
			autoStopTimer: autoStopTimer,
			timerScheduler: timerScheduler ?? TimerSchedulerSpy(),
		)
		return (sut, mover, sleepPreventer)
	}
}
