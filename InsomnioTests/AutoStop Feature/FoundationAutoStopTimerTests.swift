//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
struct FoundationAutoStopTimerTests {
	@Test
	func `Init is not running`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.isRunning == false)
	}

	@Test
	func `Init remaining time is zero`() {
		let (sut, _, _) = makeSUT()

		#expect(sut.remainingTime == 0)
	}

	@Test
	func `Start sets isRunning to true`() {
		let (sut, _, _) = makeSUT()

		sut.start(duration: .oneHour) {}

		#expect(sut.isRunning == true)
	}

	@Test
	func `Start sets remaining time to duration seconds`() {
		let (sut, _, _) = makeSUT()

		sut.start(duration: .thirtyMinutes) {}

		#expect(sut.remainingTime == 1800)
	}

	@Test
	func `Start schedules timer with one second interval`() {
		let (sut, _, timerScheduler) = makeSUT()

		sut.start(duration: .oneHour) {}

		#expect(timerScheduler.receivedMessages == [.schedule(interval: 1)])
	}

	@Test
	func `Cancel sets isRunning to false`() {
		let (sut, _, _) = makeSUT()
		sut.start(duration: .oneHour) {}

		sut.cancel()

		#expect(sut.isRunning == false)
	}

	@Test
	func `Cancel resets remaining time to zero`() {
		let (sut, _, _) = makeSUT()
		sut.start(duration: .oneHour) {}

		sut.cancel()

		#expect(sut.remainingTime == 0)
	}

	@Test
	func `Cancel invalidates scheduled timer`() {
		let (sut, _, timerScheduler) = makeSUT()
		sut.start(duration: .oneHour) {}

		sut.cancel()

		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	@Test
	func `Timer fire updates remaining time`() {
		var currentDate = Date()
		let (sut, _, timerScheduler) = makeSUT(now: { currentDate })

		sut.start(duration: .oneHour) {}
		currentDate = currentDate.addingTimeInterval(10)
		timerScheduler.fire(at: 0)

		#expect(sut.remainingTime == 3590)
	}

	@Test
	func `Timer fire at expiration calls onExpired and cancels`() {
		var currentDate = Date()
		var expiredCalled = false
		let (sut, _, timerScheduler) = makeSUT(now: { currentDate })

		sut.start(duration: .thirtyMinutes) { expiredCalled = true }
		currentDate = currentDate.addingTimeInterval(1800)
		timerScheduler.fire(at: 0)

		#expect(expiredCalled == true)
		#expect(sut.isRunning == false)
		#expect(sut.remainingTime == 0)
	}

	@Test
	func `Timer fire before expiration does not call onExpired`() {
		var currentDate = Date()
		var expiredCalled = false
		let (sut, _, timerScheduler) = makeSUT(now: { currentDate })

		sut.start(duration: .oneHour) { expiredCalled = true }
		currentDate = currentDate.addingTimeInterval(500)
		timerScheduler.fire(at: 0)

		#expect(expiredCalled == false)
		#expect(sut.isRunning == true)
	}

	@Test
	func `Start cancels previous timer before starting new one`() {
		var firstExpiredCalled = false
		let (sut, _, timerScheduler) = makeSUT()

		sut.start(duration: .oneHour) { firstExpiredCalled = true }
		sut.start(duration: .thirtyMinutes) {}

		#expect(sut.remainingTime == 1800)
		#expect(firstExpiredCalled == false)
		#expect(timerScheduler.receivedMessages.contains(.invalidate))
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak after start and cancel`() {
		assertNoLeaks {
			let (sut, _, timerScheduler) = makeSUT()
			sut.start(duration: .oneHour) {}
			sut.cancel()
			return [sut, timerScheduler]
		}
	}

	// MARK: - Helpers

	private func makeSUT(
		now: @escaping () -> Date = { Date() },
	) -> (sut: FoundationAutoStopTimer, now: () -> Date, timerScheduler: TimerSchedulerSpy) {
		let timerScheduler = TimerSchedulerSpy()
		let sut = FoundationAutoStopTimer(timerScheduler: timerScheduler, now: now)
		return (sut, now, timerScheduler)
	}
}
