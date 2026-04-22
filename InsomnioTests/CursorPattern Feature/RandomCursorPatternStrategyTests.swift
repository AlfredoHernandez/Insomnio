//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

struct RandomCursorPatternStrategyTests {
	@Test
	func `Returns single point with deterministic source`() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { 0.5 })

		let result = sut.points(from: CGPoint(x: 100, y: 100))

		#expect(result == [CGPoint(x: 102.5, y: 102.5)])
	}

	@Test
	func `Returns point at max radius with source returning 1.0`() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { 1.0 })
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 105, y: 105)])
	}

	@Test
	func `Negative random source produces negative offset`() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { -1.0 })
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 95, y: 95)])
	}
}
