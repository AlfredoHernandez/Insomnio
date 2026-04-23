//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics
import CursorPattern
import Testing

struct CircleCursorPatternStrategyTests {
	@Test
	func `Returns expected number of points`() {
		let sut = CircleCursorPatternStrategy(radius: 3, steps: 8)

		let result = sut.points(from: .zero)

		#expect(result.count == 8)
	}

	@Test
	func `First point is at 0 degrees (to the right)`() {
		let sut = CircleCursorPatternStrategy(radius: 3, steps: 8)
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result[0].x == 103)
		#expect(result[0].y == 100)
	}

	@Test
	func `All points are within radius of origin`() {
		let sut = CircleCursorPatternStrategy(radius: 3, steps: 8)
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		for point in result {
			let dx = point.x - origin.x
			let dy = point.y - origin.y
			let distance = sqrt(dx * dx + dy * dy)
			#expect(abs(distance - 3) < 0.001)
		}
	}
}
