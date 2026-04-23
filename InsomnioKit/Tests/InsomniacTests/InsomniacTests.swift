//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import AutoStopTesting
import CoreGraphics
import CursorPattern
import Foundation
import Insomniac
import InsomniacTesting
import Testing
import TestSupport
import TimerSchedulerTesting

@MainActor
struct InsomniacTests {
	@Test
	func `Init does not message mouse mover upon creation`() {
		let (_, mover, _) = makeSUT()

		#expect(mover.receivedMessages == [])
	}

	@Test
	func `Init does not message sleep preventer upon creation`() {
		let (_, _, sleepPreventer) = makeSUT()

		#expect(sleepPreventer.receivedMessages == [])
	}

	@Test
	func `Init is not active`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.isActive == false)
	}

	@Test
	func `Init default interval is 30 seconds`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.interval == 30.0)
	}

	@Test
	func `Init default mode is moveCursor`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.mode == .moveCursor)
	}

	@Test
	func `Init activation count is zero`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.activationCount == 0)
	}

	@Test
	func `Init last activation is nil`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.lastActivation == nil)
	}

	@Test
	func `Start sets isActive to true`() {
		let (sut, _, _) = makeSUT()

		sut.start()

		#expect(sut.isActive == true)
	}

	@Test
	func `Start creates assertion in preventSleep mode`() {
		let (sut, _, sleepPreventer) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	@Test
	func `Start increments activation count in preventSleep mode`() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.activationCount == 1)
	}

	@Test
	func `Start sets last activation in preventSleep mode`() {
		let (sut, _, _) = makeSUT()
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.lastActivation != nil)
	}

	@Test
	func `Start uses injected clock for lastActivation in preventSleep mode`() {
		let fixed = Date(timeIntervalSince1970: 1_700_000_000)
		let (sut, _, _) = makeSUT(now: { fixed })
		sut.mode = .preventSleep

		sut.start()

		#expect(sut.lastActivation == fixed)
	}

	@Test
	func `keepAwake uses injected clock for lastActivation`() {
		let fixed = Date(timeIntervalSince1970: 1_700_000_001)
		let (sut, _, _) = makeSUT(now: { fixed })

		sut.keepAwake()

		#expect(sut.lastActivation == fixed)
	}

	@Test
	func `Start does not start twice`() {
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

	@Test
	func `Stop sets isActive to false`() {
		let (sut, _, _) = makeSUT()

		sut.start()
		sut.stop()

		#expect(sut.isActive == false)
	}

	@Test
	func `Stop releases assertion`() {
		let (sut, _, sleepPreventer) = makeSUT()

		sut.start()
		sut.stop()

		#expect(sleepPreventer.receivedMessages == [.releaseAssertion])
	}

	@Test
	func `Stop releases assertion in preventSleep mode`() {
		let (sut, _, sleepPreventer) = makeSUT()
		sut.mode = .preventSleep

		sut.start()
		sut.stop()

		#expect(sleepPreventer.receivedMessages == [.createAssertion, .releaseAssertion])
	}

	@Test
	func `Toggle starts when inactive`() {
		let (sut, _, _) = makeSUT()

		sut.toggle()

		#expect(sut.isActive == true)
	}

	@Test
	func `Toggle stops when active`() {
		let (sut, _, _) = makeSUT()

		sut.start()
		sut.toggle()

		#expect(sut.isActive == false)
	}

	@Test
	func `keepAwake moves cursor right then back to original`() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.keepAwake()

		#expect(mover.receivedMessages == [
			.currentLocation,
			.moveTo(CGPoint(x: 70, y: 75)),
			.moveTo(CGPoint(x: 50, y: 75)),
		])
	}

	@Test
	func `keepAwake increments activation count`() {
		let (sut, _, _) = makeSUT()

		sut.keepAwake()
		sut.keepAwake()

		#expect(sut.activationCount == 2)
	}

	@Test
	func `keepAwake sets last activation`() {
		let (sut, _, _) = makeSUT()

		sut.keepAwake()

		#expect(sut.lastActivation != nil)
	}

	// MARK: - Idle Feature Tests

	@Test
	func `Init onlyWhenIdle defaults to false`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.onlyWhenIdle == false)
	}

	@Test
	func `keepAwake when onlyWhenIdle and user active does not move cursor`() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, mover, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 2.0

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test
	func `keepAwake when onlyWhenIdle and user idle moves cursor`() {
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

	@Test
	func `keepAwake when onlyWhenIdle disabled always moves`() {
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

	@Test
	func `keepAwake when onlyWhenIdle and user active does not increment count`() {
		let idleTimeProvider = IdleTimeProviderSpy()
		let (sut, _, _) = makeSUT(idleTimeProvider: idleTimeProvider)
		sut.onlyWhenIdle = true
		idleTimeProvider.stubbedIdleTime = 2.0

		sut.keepAwake()

		#expect(sut.activationCount == 0)
	}

	// MARK: - Battery Feature Tests

	@Test
	func `Init pauseOnBattery defaults to false`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.pauseOnBattery == false)
	}

	@Test
	func `keepAwake when pauseOnBattery and on battery does not move cursor`() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, mover, _) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.keepAwake()

		#expect(mover.receivedMessages == [])
	}

	@Test
	func `keepAwake when pauseOnBattery and on AC moves cursor`() {
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

	@Test
	func `keepAwake when pauseOnBattery disabled always moves`() {
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

	@Test
	func `Start preventSleep with pauseOnBattery and on battery does not create assertion`() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, _, sleepPreventer) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.start()

		#expect(!sleepPreventer.receivedMessages.contains(.createAssertion))
	}

	@Test
	func `Start preventSleep with pauseOnBattery and on AC creates assertion`() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let (sut, _, sleepPreventer) = makeSUT(powerSourceProvider: powerSourceProvider)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = false

		sut.start()

		#expect(sleepPreventer.receivedMessages == [.createAssertion])
	}

	@Test
	func `Start on battery then first power check tick on battery does not release assertion`() {
		let powerSourceProvider = PowerSourceProviderSpy()
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, sleepPreventer) = makeSUT(
			powerSourceProvider: powerSourceProvider,
			timerScheduler: timerScheduler,
		)
		sut.mode = .preventSleep
		sut.pauseOnBattery = true
		powerSourceProvider.stubbedIsOnBattery = true

		sut.start()
		timerScheduler.fire(at: 0)

		#expect(sleepPreventer.receivedMessages == [])
	}

	// MARK: - Cursor Pattern Tests

	@Test
	func `Init default cursor pattern is nudge`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.cursorPattern == .nudge)
	}

	@Test
	func `keepAwake with circle pattern moves cursor through circle points then back`() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 100, y: 100)
		sut.cursorPattern = .circle

		sut.keepAwake()

		let messages = mover.receivedMessages
		#expect(messages.first == .currentLocation)
		#expect(messages.last == .moveTo(CGPoint(x: 100, y: 100)))
		#expect(messages.count == 10)
	}

	@Test
	func `keepAwake with zigzag pattern moves cursor through zigzag points then back`() {
		let (sut, mover, _) = makeSUT()
		mover.stubbedLocation = CGPoint(x: 50, y: 50)
		sut.cursorPattern = .zigzag

		sut.keepAwake()

		let messages = mover.receivedMessages
		#expect(messages.first == .currentLocation)
		#expect(messages.last == .moveTo(CGPoint(x: 50, y: 50)))
		#expect(messages.count == 6)
	}

	// MARK: - Auto-Stop Tests

	@Test
	func `Init autoStopEnabled defaults to false`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopEnabled == false)
	}

	@Test
	func `Init autoStopDuration defaults to one hour`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopDuration == .oneHour)
	}

	@Test
	func `Start with autoStop enabled starts auto-stop timer`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true
		sut.autoStopDuration = .twoHours

		sut.start()

		#expect(autoStopTimer.receivedMessages == [.start(7200)])
	}

	@Test
	func `Start with autoStop disabled does not start auto-stop timer`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = false

		sut.start()

		#expect(autoStopTimer.receivedMessages == [])
	}

	@Test
	func `Stop cancels auto-stop timer`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()
		sut.stop()

		#expect(autoStopTimer.receivedMessages == [.start(3600), .cancel])
	}

	@Test
	func `Auto-stop timer expiration stops insomniac`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()
		#expect(sut.isActive == true)

		autoStopTimer.simulateExpiration()

		#expect(sut.isActive == false)
	}

	@Test
	func `autoStopRemainingTime delegates to timer`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopRemainingTime == autoStopTimer.remainingTime)
	}

	@Test
	func `autoStopIsRunning delegates to timer`() {
		let autoStopTimer = AutoStopTimerSpy()
		let (sut, _, _) = makeSUT(autoStopTimer: autoStopTimer)
		sut.autoStopEnabled = true

		sut.start()

		#expect(sut.autoStopIsRunning == autoStopTimer.isRunning)
	}

	@Test
	func `autoStopRemainingTime returns zero when no timer`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopRemainingTime == 0)
	}

	@Test
	func `autoStopIsRunning returns false when no timer`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.autoStopIsRunning == false)
	}

	// MARK: - Timer Scheduler Tests

	@Test
	func `Start in moveCursor mode schedules timer with configured interval`() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(timerScheduler: timerScheduler)
		sut.interval = 45

		sut.start()

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 45)])
	}

	@Test
	func `Start in moveCursor mode timer fire calls keepAwake`() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, mover, _) = makeSUT(timerScheduler: timerScheduler)
		mover.stubbedLocation = CGPoint(x: 50, y: 75)

		sut.start()
		timerScheduler.fire(at: 0)

		#expect(mover.receivedMessages.contains(.currentLocation))
	}

	@Test
	func `Stop invalidates scheduled timer`() {
		let timerScheduler = TimerSchedulerSpy()
		let (sut, _, _) = makeSUT(timerScheduler: timerScheduler)

		sut.start()
		sut.stop()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	@Test
	func `Start in preventSleep with pauseOnBattery schedules power check timer`() {
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

	@Test
	func `makeSUT does not leak after start and stop`() {
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
		now: @escaping () -> Date = { Date() },
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
			now: now,
		)
		return (sut, mover, sleepPreventer)
	}
}
