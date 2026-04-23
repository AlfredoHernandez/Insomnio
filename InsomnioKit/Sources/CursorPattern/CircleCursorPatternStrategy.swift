//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

public nonisolated struct CircleCursorPatternStrategy: CursorPatternStrategy {
	public let radius: CGFloat
	public let steps: Int

	public init(radius: CGFloat = 50, steps: Int = 8) {
		self.radius = radius
		self.steps = steps
	}

	public func points(from origin: CGPoint) -> [CGPoint] {
		(0 ..< steps).map { i in
			let angle = (2.0 * .pi / Double(steps)) * Double(i)
			return CGPoint(
				x: origin.x + radius * cos(angle),
				y: origin.y + radius * sin(angle),
			)
		}
	}
}
