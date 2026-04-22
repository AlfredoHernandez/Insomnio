//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@Observable
final class Insomniac {
	enum Mode: CaseIterable {
		case moveCursor
		case preventSleep
	}

	private let mouseMover: any MouseMover
	private let sleepPreventer: any SleepPreventer
	private let idleTimeProvider: (any IdleTimeProvider)?
	private let powerSourceProvider: (any PowerSourceProvider)?
	private let autoStopTimer: (any AutoStopTimer)?
	private let timerScheduler: any TimerScheduler
	private let now: () -> Date
	private var timer: TimerCancellable?
	private var powerCheckTimer: TimerCancellable?
	private var wasOnBattery = false

	static let idleThreshold: TimeInterval = 5.0

	private(set) var isActive: Bool = false
	var mode: Mode = .moveCursor
	var interval: TimeInterval = 30.0
	var onlyWhenIdle: Bool = false
	var pauseOnBattery: Bool = false
	var autoStopEnabled: Bool = false
	var autoStopDuration: AutoStopDuration = .oneHour
	var cursorPattern: CursorPattern = .nudge
	var onToggle: (() -> Void)?
	private(set) var activationCount: Int = 0
	private(set) var lastActivation: Date?

	var autoStopRemainingTime: TimeInterval {
		autoStopTimer?.remainingTime ?? 0
	}

	var autoStopIsRunning: Bool {
		autoStopTimer?.isRunning ?? false
	}

	init(
		mouseMover: any MouseMover,
		sleepPreventer: any SleepPreventer,
		idleTimeProvider: (any IdleTimeProvider)? = nil,
		powerSourceProvider: (any PowerSourceProvider)? = nil,
		autoStopTimer: (any AutoStopTimer)? = nil,
		timerScheduler: any TimerScheduler,
		now: @escaping () -> Date = { Date() },
	) {
		self.mouseMover = mouseMover
		self.sleepPreventer = sleepPreventer
		self.idleTimeProvider = idleTimeProvider
		self.powerSourceProvider = powerSourceProvider
		self.autoStopTimer = autoStopTimer
		self.timerScheduler = timerScheduler
		self.now = now
	}

	func toggle() {
		isActive ? stop() : start()
		onToggle?()
	}

	func start() {
		guard !isActive else { return }
		isActive = true
		switch mode {
		case .moveCursor:
			scheduleTimer()

		case .preventSleep:
			if pauseOnBattery, let powerSourceProvider, powerSourceProvider.isOnBatteryPower() {
				schedulePowerCheckTimer()
			} else {
				sleepPreventer.createAssertion()
				activationCount += 1
				lastActivation = now()
				if pauseOnBattery {
					schedulePowerCheckTimer()
				}
			}
		}
		if autoStopEnabled {
			autoStopTimer?.start(duration: autoStopDuration) { [weak self] in
				self?.stop()
			}
		}
	}

	func stop() {
		isActive = false
		timer?.invalidate()
		timer = nil
		powerCheckTimer?.invalidate()
		powerCheckTimer = nil
		wasOnBattery = false
		sleepPreventer.releaseAssertion()
		autoStopTimer?.cancel()
	}

	func keepAwake() {
		if pauseOnBattery, let powerSourceProvider, powerSourceProvider.isOnBatteryPower() {
			return
		}
		if onlyWhenIdle, let idleTimeProvider {
			let idleTime = idleTimeProvider.secondsSinceLastUserInput()
			guard idleTime >= Self.idleThreshold else { return }
		}
		let currentPosition = mouseMover.currentMouseLocation()
		let waypoints = cursorPattern.strategy.points(from: currentPosition)
		for point in waypoints {
			_ = mouseMover.moveMouseTo(point)
		}
		_ = mouseMover.moveMouseTo(currentPosition)
		activationCount += 1
		lastActivation = now()
	}

	// MARK: - Private

	private func scheduleTimer() {
		timer?.invalidate()
		timer = timerScheduler.schedule(interval: interval, repeats: true) { [weak self] in
			self?.keepAwake()
		}
	}

	private func schedulePowerCheckTimer() {
		powerCheckTimer?.invalidate()
		powerCheckTimer = timerScheduler.schedule(interval: 30, repeats: true) { [weak self] in
			self?.checkPowerSource()
		}
	}

	private func checkPowerSource() {
		guard let powerSourceProvider else { return }
		let onBattery = powerSourceProvider.isOnBatteryPower()
		if onBattery, !wasOnBattery {
			sleepPreventer.releaseAssertion()
		} else if !onBattery, wasOnBattery {
			sleepPreventer.createAssertion()
			activationCount += 1
			lastActivation = now()
		}
		wasOnBattery = onBattery
	}
}
