//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

public nonisolated struct ZigzagCursorPatternStrategy: CursorPatternStrategy {
	public let offset: CGFloat

	public init(offset: CGFloat = 30) {
		self.offset = offset
	}

	public func points(from origin: CGPoint) -> [CGPoint] {
		[
			CGPoint(x: origin.x + offset, y: origin.y - offset),
			CGPoint(x: origin.x - offset, y: origin.y + offset),
			CGPoint(x: origin.x + offset, y: origin.y + offset),
			CGPoint(x: origin.x - offset, y: origin.y - offset),
		]
	}
}
