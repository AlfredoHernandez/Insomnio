//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@Observable
final class FoundationAutoStopTimer: AutoStopTimerProtocol {
	private(set) var isRunning: Bool = false
	private(set) var remainingTime: TimeInterval = 0

	private var timer: Timer?
	private var expirationDate: Date?
	private var onExpired: (() -> Void)?

	func start(duration: AutoStopDuration, onExpired: @escaping () -> Void) {
		cancel()
		self.onExpired = onExpired
		remainingTime = duration.seconds
		expirationDate = Date().addingTimeInterval(duration.seconds)
		isRunning = true

		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			self?.tick()
		}
	}

	func cancel() {
		timer?.invalidate()
		timer = nil
		isRunning = false
		remainingTime = 0
		expirationDate = nil
		onExpired = nil
	}

	private func tick() {
		guard let expirationDate else { return }
		remainingTime = max(0, expirationDate.timeIntervalSinceNow)
		if remainingTime <= 0 {
			let callback = onExpired
			cancel()
			callback?()
		}
	}
}
