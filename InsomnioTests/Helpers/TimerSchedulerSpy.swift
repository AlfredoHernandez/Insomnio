//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation

@MainActor
final class TimerSchedulerSpy: TimerScheduler {
	enum ReceivedMessage: Equatable {
		case schedule(interval: TimeInterval)
		case invalidate
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	private var blocks: [@MainActor () -> Void] = []

	func schedule(interval: TimeInterval, repeats _: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable {
		receivedMessages.append(.schedule(interval: interval))
		blocks.append(block)
		return Cancellable(spy: self)
	}

	func fire(at index: Int) {
		blocks[index]()
	}

	func recordInvalidation() {
		receivedMessages.append(.invalidate)
	}

	// MARK: - Helpers

	private final class Cancellable: TimerCancellable {
		private let spy: TimerSchedulerSpy

		init(spy: TimerSchedulerSpy) {
			self.spy = spy
		}

		func invalidate() {
			spy.recordInvalidation()
		}
	}
}
