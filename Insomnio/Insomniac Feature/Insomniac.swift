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

	private let mouseMover: MouseMover
	private let sleepPreventer: SleepPreventer
	private let idleTimeProvider: IdleTimeProvider?
	private let powerSourceProvider: PowerSourceProvider?
	private var timer: Timer?
	private var powerCheckTimer: Timer?
	private var wasOnBattery = false

	static let idleThreshold: TimeInterval = 5.0

	var isActive: Bool = false
	var mode: Mode = .moveCursor
	var interval: TimeInterval = 30.0
	var onlyWhenIdle: Bool = false
	var pauseOnBattery: Bool = false
	private(set) var activationCount: Int = 0
	private(set) var lastActivation: Date?

	init(
		mouseMover: MouseMover,
		sleepPreventer: SleepPreventer,
		idleTimeProvider: IdleTimeProvider? = nil,
		powerSourceProvider: PowerSourceProvider? = nil,
	) {
		self.mouseMover = mouseMover
		self.sleepPreventer = sleepPreventer
		self.idleTimeProvider = idleTimeProvider
		self.powerSourceProvider = powerSourceProvider
	}

	func toggle() {
		isActive ? stop() : start()
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
				_ = sleepPreventer.createAssertion()
				activationCount += 1
				lastActivation = Date()
				if pauseOnBattery {
					schedulePowerCheckTimer()
				}
			}
		}
	}

	func stop() {
		isActive = false
		timer?.invalidate()
		timer = nil
		powerCheckTimer?.invalidate()
		powerCheckTimer = nil
		sleepPreventer.releaseAssertion()
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
		let nudged = CGPoint(x: currentPosition.x + 1, y: currentPosition.y)
		_ = mouseMover.moveMouseTo(nudged)
		_ = mouseMover.moveMouseTo(currentPosition)
		activationCount += 1
		lastActivation = Date()
	}

	// MARK: - Private

	private func scheduleTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
			self?.keepAwake()
		}
	}

	private func schedulePowerCheckTimer() {
		powerCheckTimer?.invalidate()
		powerCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
			self?.checkPowerSource()
		}
	}

	private func checkPowerSource() {
		guard let powerSourceProvider else { return }
		let onBattery = powerSourceProvider.isOnBatteryPower()
		if onBattery, !wasOnBattery {
			sleepPreventer.releaseAssertion()
		} else if !onBattery, wasOnBattery {
			_ = sleepPreventer.createAssertion()
			activationCount += 1
			lastActivation = Date()
		}
		wasOnBattery = onBattery
	}
}
