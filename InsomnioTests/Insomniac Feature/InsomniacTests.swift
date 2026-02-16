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

	@Test("Start in preventSleep mode creates assertion")
	func start_createsAssertionInPreventSleepMode() {
		let (sut, _, sleepPreventer) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	@Test("Start in preventSleep mode increments activation count")
	func start_incrementsActivationCountInPreventSleepMode() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.activationCount == 1)
	}

	@Test("Start in preventSleep mode sets lastActivation")
	func start_setsLastActivationInPreventSleepMode() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.lastActivation != nil)
	}

	@Test("Start does not start twice")
	func start_doesNotStartTwice() {
		let (sut, _, _) = makeSUT()

		sut.start()
		sut.start()

		#expect(sut.isActive == true)
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

	@Test("Stop in preventSleep mode releases assertion")
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

	@Test("Keep awake moves cursor right then back to original")
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

	@Test("Keep awake increments activation count")
	func keepAwake_incrementsActivationCount() {
		let (sut, _, _) = makeSUT()

		sut.keepAwake()
		sut.keepAwake()

		#expect(sut.activationCount == 2)
	}

	@Test("Keep awake sets lastActivation")
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

	@Test("Keep awake when onlyWhenIdle and user active does not move cursor")
	func keepAwake_whenOnlyWhenIdleAndUserActive_doesNotMoveCursor() {
		let (sut, mover, idleTimeProvider) = makeSUTWithIdleProvider()
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 2.0

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test("Keep awake when onlyWhenIdle and user idle moves cursor")
	func keepAwake_whenOnlyWhenIdleAndUserIdle_movesCursor() {
		let (sut, mover, idleTimeProvider) = makeSUTWithIdleProvider()
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

	@Test("Keep awake when onlyWhenIdle disabled always moves")
	func keepAwake_whenOnlyWhenIdleDisabled_alwaysMoves() {
		let (sut, mover, idleTimeProvider) = makeSUTWithIdleProvider()
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

	@Test("Keep awake when onlyWhenIdle and user active does not increment count")
	func keepAwake_whenOnlyWhenIdleAndUserActive_doesNotIncrementCount() {
		let (sut, _, idleTimeProvider) = makeSUTWithIdleProvider()
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

	@Test("Keep awake when pauseOnBattery and on battery does not move cursor")
	func keepAwake_whenPauseOnBatteryAndOnBattery_doesNotMoveCursor() {
		let (sut, mover, _, powerSourceProvider) = makeSUTWithPowerProvider()
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test("Keep awake when pauseOnBattery and on AC moves cursor")
	func keepAwake_whenPauseOnBatteryAndOnAC_movesCursor() {
		let (sut, mover, _, powerSourceProvider) = makeSUTWithPowerProvider()
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

	@Test("Keep awake when pauseOnBattery disabled always moves")
	func keepAwake_whenPauseOnBatteryDisabled_alwaysMoves() {
		let (sut, mover, _, powerSourceProvider) = makeSUTWithPowerProvider()
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

	@Test("Start preventSleep and pauseOnBattery and on battery does not create assertion")
	func start_preventSleepAndPauseOnBatteryAndOnBattery_doesNotCreateAssertion() {
		let (sut, _, sleepPreventer, powerSourceProvider) = makeSUTWithPowerProvider()
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.start()

		#expect(!sleepPreventer.receivedMessages.contains(.createAssertion))
	}

	@Test("Start preventSleep and pauseOnBattery and on AC creates assertion")
	func start_preventSleepAndPauseOnBatteryAndOnAC_createsAssertion() {
		let (sut, _, sleepPreventer, powerSourceProvider) = makeSUTWithPowerProvider()
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = false

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	// MARK: - Cursor Pattern Tests

	@Test("Init default cursorPattern is nudge")
	func init_defaultCursorPatternIsNudge() {
		let (sut, _, _) = makeSUT()

		#expect(sut.cursorPattern == .nudge)
	}

	@Test("Keep awake with circle pattern moves cursor through circle points then back")
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

	@Test("Keep awake with zigzag pattern moves cursor through zigzag points then back")
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

	@Test("Init autoStopDuration defaults to oneHour")
	func init_autoStopDurationDefaultsToOneHour() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopDuration == .oneHour)
	}

	@Test("Start with autoStop enabled starts auto-stop timer")
	func start_withAutoStopEnabled_startsAutoStopTimer() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = true
		sut.autoStopDuration = .twoHours

		sut.start()

		#expect(autoStopTimer.receivedMessages == [.start(7200)])
	}

	@Test("Start with autoStop disabled does not start auto-stop timer")
	func start_withAutoStopDisabled_doesNotStartAutoStopTimer() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = false

		sut.start()

		#expect(autoStopTimer.receivedMessages == [])
	}

	@Test("Stop cancels auto-stop timer")
	func stop_cancelsAutoStopTimer() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = true

		sut.start()
		sut.stop()

		#expect(autoStopTimer.receivedMessages == [.start(3600), .cancel])
	}

	@Test("Auto-stop timer expiration stops insomniac")
	func autoStopTimerExpiration_stopsInsomniac() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = true

		sut.start()
		#expect(sut.isActive == true)

		autoStopTimer.simulateExpiration()

		#expect(sut.isActive == false)
	}

	@Test("AutoStop remaining time delegates to timer")
	func autoStopRemainingTime_delegatesToTimer() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopRemainingTime == autoStopTimer.remainingTime)
	}

	@Test("AutoStop isRunning delegates to timer")
	func autoStopIsRunning_delegatesToTimer() {
		let (sut, autoStopTimer) = makeSUTWithAutoStopTimer()
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopIsRunning == autoStopTimer.isRunning)
	}

	@Test("AutoStop remaining time returns zero when no timer")
	func autoStopRemainingTime_returnsZeroWhenNoTimer() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopRemainingTime == 0)
	}

	@Test("AutoStop isRunning returns false when no timer")
	func autoStopIsRunning_returnsFalseWhenNoTimer() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopIsRunning == false)
	}

	// MARK: - Timer Scheduler Tests

	@Test("Start in moveCursor mode schedules timer with configured interval")
	func start_moveCursor_schedulesTimerWithConfiguredInterval() {
		let (sut, _, _, timerScheduler) = makeSUTWithTimerScheduler()
		sut.interval = 45

		sut.start()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 45)])
	}

	@Test("Start in moveCursor mode timer fire calls keepAwake")
	func start_moveCursor_timerFireCallsKeepAwake() {
		let (sut, mover, _, timerScheduler) = makeSUTWithTimerScheduler()
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.start()
		timerScheduler.fire(at: 0)

		#expect(mover.receivedMessages.contains(.currentLocation))
	}

	@Test("Stop invalidates scheduled timer")
	func stop_invalidatesScheduledTimer() {
		let (sut, _, _, timerScheduler) = makeSUTWithTimerScheduler()

		sut.start()
		sut.stop()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	@Test("Start in preventSleep with pauseOnBattery schedules power check timer")
	func start_preventSleep_pauseOnBattery_schedulesPowerCheckTimer() {
		let powerSourceProvider = PowerSourceProviderSpy()
		powerSourceProvider.stubbedIsOnBattery = false
		let timerScheduler = TimerSchedulerSpy()
		let sut = Insomniac(
			mouseMover: MouseMoverSpy(),
			sleepPreventer: SleepPreventerSpy(),
			powerSourceProvider: powerSourceProvider,
			timerScheduler: timerScheduler,
		)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true

		sut.start()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 30)])
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: Insomniac, mover: MouseMoverSpy, sleepPreventer: SleepPreventerSpy) {
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer)
		return (sut, mover, sleepPreventer)
	}

	private func makeSUTWithIdleProvider() -> (sut: Insomniac, mover: MouseMoverSpy, idleTimeProvider: IdleTimeProviderSpy) {
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let idleTimeProvider = IdleTimeProviderSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer, idleTimeProvider: idleTimeProvider)
		return (sut, mover, idleTimeProvider)
	}

	private func makeSUTWithPowerProvider()
		-> (sut: Insomniac, mover: MouseMoverSpy, sleepPreventer: SleepPreventerSpy, powerSourceProvider: PowerSourceProviderSpy)
	{
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let powerSourceProvider = PowerSourceProviderSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer, powerSourceProvider: powerSourceProvider)
		return (sut, mover, sleepPreventer, powerSourceProvider)
	}

	private func makeSUTWithProviders()
		-> (
			sut: Insomniac,
			mover: MouseMoverSpy,
			sleepPreventer: SleepPreventerSpy,
			idleTimeProvider: IdleTimeProviderSpy,
			powerSourceProvider: PowerSourceProviderSpy,
		)
	{
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let idleTimeProvider = IdleTimeProviderSpy()
		let powerSourceProvider = PowerSourceProviderSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer, idleTimeProvider: idleTimeProvider, powerSourceProvider: powerSourceProvider)
		return (sut, mover, sleepPreventer, idleTimeProvider, powerSourceProvider)
	}

	private func makeSUTWithAutoStopTimer() -> (sut: Insomniac, autoStopTimer: AutoStopTimerSpy) {
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let autoStopTimer = AutoStopTimerSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer, autoStopTimer: autoStopTimer)
		return (sut, autoStopTimer)
	}

	private func makeSUTWithTimerScheduler()
		-> (sut: Insomniac, mover: MouseMoverSpy, sleepPreventer: SleepPreventerSpy, timerScheduler: TimerSchedulerSpy)
	{
		let mover = MouseMoverSpy()
		let sleepPreventer = SleepPreventerSpy()
		let timerScheduler = TimerSchedulerSpy()
		let sut = Insomniac(mouseMover: mover, sleepPreventer: sleepPreventer, timerScheduler: timerScheduler)
		return (sut, mover, sleepPreventer, timerScheduler)
	}
}
