//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

public nonisolated struct RandomCursorPatternStrategy: CursorPatternStrategy {
	public let radius: CGFloat
	public let randomSource: @Sendable () -> CGFloat

	public init(radius: CGFloat = 50, randomSource: @escaping @Sendable () -> CGFloat = { CGFloat.random(in: -1 ... 1) }) {
		self.radius = radius
		self.randomSource = randomSource
	}

	public func points(from origin: CGPoint) -> [CGPoint] {
		let dx = randomSource() * radius
		let dy = randomSource() * radius
		return [CGPoint(x: origin.x + dx, y: origin.y + dy)]
	}
}
