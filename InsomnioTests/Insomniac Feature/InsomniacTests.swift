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
			.moveTo(CGPoint(x: 51, y: 75)),
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
			.moveTo(CGPoint(x: 51, y: 75)),
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
			.moveTo(CGPoint(x: 51, y: 75)),
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
			.moveTo(CGPoint(x: 51, y: 75)),
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
			.moveTo(CGPoint(x: 51, y: 75)),
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
}
