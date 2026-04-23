//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import Foundation

public final class AutoStopTimerSpy: AutoStopTimer {
	public enum ReceivedMessage: Equatable {
		case start(TimeInterval)
		case cancel
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public private(set) var isRunning: Bool = false
	public private(set) var remainingTime: TimeInterval = 0
	public private(set) var capturedOnExpired: (() -> Void)?

	public init() {}

	public func start(duration: AutoStopDuration, onExpired: @escaping () -> Void) {
		receivedMessages.append(.start(duration.seconds))
		isRunning = true
		remainingTime = duration.seconds
		capturedOnExpired = onExpired
	}

	public func cancel() {
		receivedMessages.append(.cancel)
		isRunning = false
		remainingTime = 0
		capturedOnExpired = nil
	}

	public func simulateExpiration() {
		let callback = capturedOnExpired
		isRunning = false
		remainingTime = 0
		capturedOnExpired = nil
		callback?()
	}
}
