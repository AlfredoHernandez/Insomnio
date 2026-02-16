//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

struct CGMouseMover: MouseMover {
	func moveMouseTo(_ point: CGPoint) -> Bool {
		guard let event = CGEvent(
			mouseEventSource: nil,
			mouseType: .mouseMoved,
			mouseCursorPosition: point,
			mouseButton: .left,
		) else {
			return false
		}
		event.post(tap: .cghidEventTap)
		return true
	}

	func currentMouseLocation() -> CGPoint {
		guard let event = CGEvent(source: nil) else { return .zero }
		return event.location
	}
}
