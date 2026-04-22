//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@Observable
final class FoundationAutoStopTimer: AutoStopTimer {
	private(set) var isRunning: Bool = false
	private(set) var remainingTime: TimeInterval = 0

	private var timer: Timer?
	private var expirationDate: Date?
	private var onExpired: (() -> Void)?
	private let now: () -> Date

	init(now: @escaping () -> Date = { Date() }) {
		self.now = now
	}

	func start(duration: AutoStopDuration, onExpired: @escaping () -> Void) {
		cancel()
		self.onExpired = onExpired
		remainingTime = duration.seconds
		expirationDate = now().addingTimeInterval(duration.seconds)
		isRunning = true

		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			MainActor.assumeIsolated {
				self?.tick()
			}
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

	func tick() {
		guard let expirationDate else { return }
		remainingTime = max(0, expirationDate.timeIntervalSince(now()))
		if remainingTime <= 0 {
			let callback = onExpired
			cancel()
			callback?()
		}
	}
}
