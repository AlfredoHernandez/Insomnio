//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics
import CursorPattern
import Testing

struct NudgeCursorPatternStrategyTests {
	@Test
	func `Returns single point offset to the right`() {
		let sut = NudgeCursorPatternStrategy()
		let origin = CGPoint(x: 50, y: 75)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 70, y: 75)])
	}

	@Test
	func `Returns point relative to origin`() {
		let sut = NudgeCursorPatternStrategy(offset: 3)
		let origin = CGPoint(x: 200, y: 300)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 203, y: 300)])
	}
}
