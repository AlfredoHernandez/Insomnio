//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

struct RandomCursorPatternStrategy: CursorPatternStrategy {
	let radius: CGFloat
	let randomSource: () -> CGFloat

	init(radius: CGFloat = 5, randomSource: @escaping @Sendable () -> CGFloat = { CGFloat.random(in: -1 ... 1) }) {
		self.radius = radius
		self.randomSource = randomSource
	}

	func points(from origin: CGPoint) -> [CGPoint] {
		let dx = randomSource() * radius
		let dy = randomSource() * radius
		return [CGPoint(x: origin.x + dx, y: origin.y + dy)]
	}
}
