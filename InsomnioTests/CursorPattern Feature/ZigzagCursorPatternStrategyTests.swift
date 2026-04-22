//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

struct ZigzagCursorPatternStrategyTests {
	@Test
	func `Returns four diagonal points`() {
		let sut = ZigzagCursorPatternStrategy(offset: 2)

		let result = sut.points(from: CGPoint(x: 50, y: 50))

		#expect(result.count == 4)
	}

	@Test
	func `Points alternate diagonally`() {
		let sut = ZigzagCursorPatternStrategy(offset: 2)
		let origin = CGPoint(x: 50, y: 50)

		let result = sut.points(from: origin)

		#expect(result == [
			CGPoint(x: 52, y: 48),
			CGPoint(x: 48, y: 52),
			CGPoint(x: 52, y: 52),
			CGPoint(x: 48, y: 48),
		])
	}
}
