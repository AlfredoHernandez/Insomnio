//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop
import CursorPattern
import Foundation
import TimerScheduler

@Observable
public final class Insomniac {
	public enum Mode: CaseIterable {
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

	public static let idleThreshold: TimeInterval = 5.0

	public private(set) var isActive: Bool = false
	public var mode: Mode = .moveCursor
	public var interval: TimeInterval = 30.0
	public var onlyWhenIdle: Bool = false
	public var pauseOnBattery: Bool = false
	public var autoStopEnabled: Bool = false
	public var autoStopDuration: AutoStopDuration = .oneHour
	public var cursorPattern: CursorPattern = .nudge
	public var onToggle: (() -> Void)?
	public private(set) var activationCount: Int = 0
	public private(set) var lastActivation: Date?

	public var autoStopRemainingTime: TimeInterval {
		autoStopTimer?.remainingTime ?? 0
	}

	public var autoStopIsRunning: Bool {
		autoStopTimer?.isRunning ?? false
	}

	public init(
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

	public func toggle() {
		isActive ? stop() : start()
		onToggle?()
	}

	public func start() {
		guard !isActive else { return }
		isActive = true
		switch mode {
		case .moveCursor:
			scheduleTimer()

		case .preventSleep:
			if pauseOnBattery, let powerSourceProvider, powerSourceProvider.isOnBatteryPower() {
				wasOnBattery = true
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

	public func stop() {
		isActive = false
		timer?.invalidate()
		timer = nil
		powerCheckTimer?.invalidate()
		powerCheckTimer = nil
		wasOnBattery = false
		sleepPreventer.releaseAssertion()
		autoStopTimer?.cancel()
	}

	public func keepAwake() {
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
