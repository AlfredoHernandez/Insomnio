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

	/// Where the current awake session was turned on from (menu bar, Shortcuts, etc.).
	public enum ActivationSource: String, Sendable, Equatable {
		case menuBar
		case mainWindow
		case globalShortcut
		case shortcutsIntent
		case automation
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
	private var pendingActivationSource: ActivationSource?

	public static let idleThreshold: TimeInterval = 5.0

	public private(set) var isActive: Bool = false
	/// Set when `isActive` becomes `true`; cleared on `stop()`.
	public private(set) var activationSource: ActivationSource?
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
	/// Rolling log of the most recent activation sessions, oldest-first. Capped at ``recentActivationsCapacity``.
	public private(set) var recentActivations: [ActivationEvent] = []

	/// Max number of sessions kept in ``recentActivations``.
	public static let recentActivationsCapacity: Int = 50

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

	/// Toggles awake state. When turning on, `source` is stored for UI (e.g. menu bar pill).
	public func toggle(from source: ActivationSource = .menuBar) {
		if isActive {
			stop()
		} else {
			pendingActivationSource = source
			start()
		}
		onToggle?()
	}

	/// Call immediately before `start()` when activation is not routed through `toggle(from:)`
	/// (for example automation turning the model on).
	public func registerActivationSource(_ source: ActivationSource) {
		pendingActivationSource = source
	}

	public func start() {
		guard !isActive else { return }
		activationSource = pendingActivationSource ?? .menuBar
		pendingActivationSource = nil
		isActive = true
		recordActivationStart()
		switch mode {
		case .moveCursor:
			scheduleTimer()

		case .preventSleep:
			// activationCount tracks each sleep-prevention assertion
			// (start + battery↔AC transitions). In .moveCursor, it instead
			// tracks each cursor nudge from keepAwake().
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
		let wasActive = isActive
		isActive = false
		activationSource = nil
		pendingActivationSource = nil
		timer?.invalidate()
		timer = nil
		powerCheckTimer?.invalidate()
		powerCheckTimer = nil
		wasOnBattery = false
		sleepPreventer.releaseAssertion()
		autoStopTimer?.cancel()
		if wasActive {
			recordActivationEnd()
		}
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

	private func recordActivationStart() {
		let source = activationSource ?? .menuBar
		let event = ActivationEvent(startDate: now(), source: source)
		recentActivations.append(event)
		if recentActivations.count > Self.recentActivationsCapacity {
			recentActivations.removeFirst(recentActivations.count - Self.recentActivationsCapacity)
		}
	}

	private func recordActivationEnd() {
		guard let last = recentActivations.last, last.endDate == nil else { return }
		let closed = ActivationEvent(
			id: last.id,
			startDate: last.startDate,
			endDate: now(),
			source: last.source,
		)
		recentActivations[recentActivations.count - 1] = closed
	}

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
