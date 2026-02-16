//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

@Suite("CircleCursorPatternStrategy")
struct CircleCursorPatternStrategyTests {
	@Test("Returns expected number of points")
	func points_returnsCorrectCount() {
		let sut = CircleCursorPatternStrategy(radius: 3, steps: 8)

		let result = sut.points(from: .zero)

		#expect(result.count == 8)
	}

	@Test("First point is at 0 degrees (to the right)")
	func points_firstPointIsAtZeroDegrees() {
		let sut = CircleCursorPatternStrategy(radius: 3, steps: 8)
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result[0].x == 103)
		#expect(result[0].y == 100)
	}

	@Test("All points are within radius of origin")
	func points_allPointsWithinRadius() {
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
