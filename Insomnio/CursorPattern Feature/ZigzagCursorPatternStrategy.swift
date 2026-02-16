//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

struct ZigzagCursorPatternStrategy: CursorPatternStrategy {
	let offset: CGFloat

	init(offset: CGFloat = 2) {
		self.offset = offset
	}

	func points(from origin: CGPoint) -> [CGPoint] {
		[
			CGPoint(x: origin.x + offset, y: origin.y - offset),
			CGPoint(x: origin.x - offset, y: origin.y + offset),
			CGPoint(x: origin.x + offset, y: origin.y + offset),
			CGPoint(x: origin.x - offset, y: origin.y - offset),
		]
	}
}
