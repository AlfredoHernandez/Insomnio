//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum AutoStopDuration: Hashable {
	case thirtyMinutes
	case oneHour
	case twoHours
	case fourHours
	case custom(TimeInterval)

	var seconds: TimeInterval {
		switch self {
		case .thirtyMinutes: 1800

		case .oneHour: 3600

		case .twoHours: 7200

		case .fourHours: 14400

		case let .custom(t): t
		}
	}

	static var presets: [AutoStopDuration] {
		[.thirtyMinutes, .oneHour, .twoHours, .fourHours]
	}
}

protocol AutoStopTimer: AnyObject {
	var isRunning: Bool { get }
	var remainingTime: TimeInterval { get }
	func start(duration: AutoStopDuration, onExpired: @escaping () -> Void)
	func cancel()
}
