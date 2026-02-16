//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

struct CircleCursorPatternStrategy: CursorPatternStrategy {
	let radius: CGFloat
	let steps: Int

	init(radius: CGFloat = 50, steps: Int = 8) {
		self.radius = radius
		self.steps = steps
	}

	func points(from origin: CGPoint) -> [CGPoint] {
		(0 ..< steps).map { i in
			let angle = (2.0 * .pi / Double(steps)) * Double(i)
			return CGPoint(
				x: origin.x + radius * cos(angle),
				y: origin.y + radius * sin(angle),
			)
		}
	}
}
