//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation
import Testing

@MainActor
@Suite("FoundationAutoStopTimer")
struct FoundationAutoStopTimerTests {
	@Test("Init is not running")
	func init_isNotRunning() {
		let (sut, _) = makeSUT()

		#expect(sut.isRunning == false)
	}

	@Test("Init remaining time is zero")
	func init_remainingTimeIsZero() {
		let (sut, _) = makeSUT()

		#expect(sut.remainingTime == 0)
	}

	@Test("Start sets isRunning to true")
	func start_setsIsRunningToTrue() {
		let (sut, _) = makeSUT()

		sut.start(duration: .oneHour) {}

		#expect(sut.isRunning == true)
	}

	@Test("Start sets remaining time to duration seconds")
	func start_setsRemainingTimeToDurationSeconds() {
		let (sut, _) = makeSUT()

		sut.start(duration: .thirtyMinutes) {}

		#expect(sut.remainingTime == 1800)
	}

	@Test("Cancel sets isRunning to false")
	func cancel_setsIsRunningToFalse() {
		let (sut, _) = makeSUT()
		sut.start(duration: .oneHour) {}

		sut.cancel()

		#expect(sut.isRunning == false)
	}

	@Test("Cancel resets remaining time to zero")
	func cancel_resetsRemainingTimeToZero() {
		let (sut, _) = makeSUT()
		sut.start(duration: .oneHour) {}

		sut.cancel()

		#expect(sut.remainingTime == 0)
	}

	@Test("Tick updates remaining time")
	func tick_updatesRemainingTime() {
		var currentDate = Date()
		let (sut, _) = makeSUT(now: { currentDate })

		sut.start(duration: .oneHour) {}
		currentDate = currentDate.addingTimeInterval(10)
		sut.tick()

		#expect(sut.remainingTime == 3590)
	}

	@Test("Tick at expiration calls onExpired and cancels")
	func tick_atExpiration_callsOnExpiredAndCancels() {
		var currentDate = Date()
		var expiredCalled = false
		let (sut, _) = makeSUT(now: { currentDate })

		sut.start(duration: .thirtyMinutes) { expiredCalled = true }
		currentDate = currentDate.addingTimeInterval(1800)
		sut.tick()

		#expect(expiredCalled == true)
		#expect(sut.isRunning == false)
		#expect(sut.remainingTime == 0)
	}

	@Test("Tick before expiration does not call onExpired")
	func tick_beforeExpiration_doesNotCallOnExpired() {
		var currentDate = Date()
		var expiredCalled = false
		let (sut, _) = makeSUT(now: { currentDate })

		sut.start(duration: .oneHour) { expiredCalled = true }
		currentDate = currentDate.addingTimeInterval(500)
		sut.tick()

		#expect(expiredCalled == false)
		#expect(sut.isRunning == true)
	}

	@Test("Start cancels previous timer before starting new one")
	func start_cancelsPreviousTimerBeforeStartingNewOne() {
		var firstExpiredCalled = false
		let (sut, _) = makeSUT()

		sut.start(duration: .oneHour) { firstExpiredCalled = true }
		sut.start(duration: .thirtyMinutes) {}

		#expect(sut.remainingTime == 1800)
		#expect(firstExpiredCalled == false)
	}

	// MARK: - Memory Leak Tracking

	@Test("makeSUT does not leak after start and cancel")
	func makeSUT_doesNotLeakAfterStartAndCancel() {
		assertNoLeaks {
			let (sut, _) = makeSUT()
			sut.start(duration: .oneHour) {}
			sut.cancel()
			return [sut]
		}
	}

	// MARK: - Helpers

	private func makeSUT(now: @escaping () -> Date = { Date() }) -> (sut: FoundationAutoStopTimer, now: () -> Date) {
		let sut = FoundationAutoStopTimer(now: now)
		return (sut, now)
	}
}
