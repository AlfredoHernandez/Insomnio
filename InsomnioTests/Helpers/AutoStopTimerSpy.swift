//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AutoStop
import Foundation

@MainActor
final class AutoStopTimerSpy: AutoStopTimer {
	enum ReceivedMessage: Equatable {
		case start(TimeInterval)
		case cancel
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	private(set) var isRunning: Bool = false
	private(set) var remainingTime: TimeInterval = 0
	private(set) var capturedOnExpired: (() -> Void)?

	func start(duration: AutoStopDuration, onExpired: @escaping () -> Void) {
		receivedMessages.append(.start(duration.seconds))
		isRunning = true
		remainingTime = duration.seconds
		capturedOnExpired = onExpired
	}

	func cancel() {
		receivedMessages.append(.cancel)
		isRunning = false
		remainingTime = 0
		capturedOnExpired = nil
	}

	func simulateExpiration() {
		let callback = capturedOnExpired
		isRunning = false
		remainingTime = 0
		capturedOnExpired = nil
		callback?()
	}
}
