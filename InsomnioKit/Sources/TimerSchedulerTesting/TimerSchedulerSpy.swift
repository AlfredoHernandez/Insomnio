//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import TimerScheduler

public final class TimerSchedulerSpy: TimerScheduler {
	public enum ReceivedMessage: Equatable {
		case schedule(interval: TimeInterval)
		case invalidate
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	private var blocks: [@MainActor () -> Void] = []

	public init() {}

	public func schedule(interval: TimeInterval, repeats _: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable {
		receivedMessages.append(.schedule(interval: interval))
		blocks.append(block)
		return Cancellable(spy: self)
	}

	public func fire(at index: Int) {
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
