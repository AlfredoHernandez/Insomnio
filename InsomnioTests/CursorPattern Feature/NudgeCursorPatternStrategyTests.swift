//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

@Suite("NudgeCursorPatternStrategy")
struct NudgeCursorPatternStrategyTests {
	@Test("Returns single point offset to the right")
	func points_returnsSinglePointOffsetRight() {
		let sut = NudgeCursorPatternStrategy()
		let origin = CGPoint(x: 50, y: 75)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 70, y: 75)])
	}

	@Test("Returns point relative to origin")
	func points_returnsPointRelativeToOrigin() {
		let sut = NudgeCursorPatternStrategy(offset: 3)
		let origin = CGPoint(x: 200, y: 300)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 203, y: 300)])
	}
}
