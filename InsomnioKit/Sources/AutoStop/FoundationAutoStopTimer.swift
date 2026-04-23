//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import TimerScheduler

@Observable
public final class FoundationAutoStopTimer: AutoStopTimer {
	public private(set) var isRunning: Bool = false
	public private(set) var remainingTime: TimeInterval = 0

	private let timerScheduler: any TimerScheduler
	private let now: () -> Date
	private var timer: TimerCancellable?
	private var expirationDate: Date?
	private var onExpired: (() -> Void)?

	public init(
		timerScheduler: any TimerScheduler = FoundationTimerScheduler(),
		now: @escaping () -> Date = { Date() },
	) {
		self.timerScheduler = timerScheduler
		self.now = now
	}

	public func start(duration: AutoStopDuration, onExpired: @escaping () -> Void) {
		cancel()
		self.onExpired = onExpired
		remainingTime = duration.seconds
		expirationDate = now().addingTimeInterval(duration.seconds)
		isRunning = true

		timer = timerScheduler.schedule(interval: 1, repeats: true) { [weak self] in
			self?.tick()
		}
	}

	public func cancel() {
		timer?.invalidate()
		timer = nil
		isRunning = false
		remainingTime = 0
		expirationDate = nil
		onExpired = nil
	}

	private func tick() {
		guard let expirationDate else { return }
		remainingTime = max(0, expirationDate.timeIntervalSince(now()))
		if remainingTime <= 0 {
			let callback = onExpired
			cancel()
			callback?()
		}
	}
}
