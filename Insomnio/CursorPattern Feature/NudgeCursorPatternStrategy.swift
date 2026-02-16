//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

struct NudgeCursorPatternStrategy: CursorPatternStrategy {
	func points(from origin: CGPoint) -> [CGPoint] {
		[CGPoint(x: origin.x + 1, y: origin.y)]
	}
}
