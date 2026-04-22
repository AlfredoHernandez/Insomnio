//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

nonisolated struct NudgeCursorPatternStrategy: CursorPatternStrategy {
	let offset: CGFloat

	init(offset: CGFloat = 20) {
		self.offset = offset
	}

	func points(from origin: CGPoint) -> [CGPoint] {
		[CGPoint(x: origin.x + offset, y: origin.y)]
	}
}
