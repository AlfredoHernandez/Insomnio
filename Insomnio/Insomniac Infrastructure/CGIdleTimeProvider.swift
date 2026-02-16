//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics
import Foundation

struct CGIdleTimeProvider: IdleTimeProvider {
	func secondsSinceLastUserInput() -> TimeInterval {
		let eventTypes: [CGEventType] = [
			.mouseMoved, .leftMouseDown, .rightMouseDown,
			.keyDown, .scrollWheel,
		]
		var minIdle: TimeInterval = .greatestFiniteMagnitude
		for eventType in eventTypes {
			let idle = CGEventSource.secondsSinceLastEventType(
				.combinedSessionState,
				eventType: eventType,
			)
			minIdle = min(minIdle, idle)
		}
		return minIdle
	}
}
