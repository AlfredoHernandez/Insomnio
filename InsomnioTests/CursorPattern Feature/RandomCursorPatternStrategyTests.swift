//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics
import Testing

@Suite("RandomCursorPatternStrategy")
struct RandomCursorPatternStrategyTests {
	@Test("Returns single point with deterministic source")
	func points_returnsSinglePoint() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { 0.5 })

		let result = sut.points(from: CGPoint(x: 100, y: 100))

		#expect(result == [CGPoint(x: 102.5, y: 102.5)])
	}

	@Test("Returns point at max radius with source returning 1.0")
	func points_returnsPointAtMaxRadius() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { 1.0 })
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 105, y: 105)])
	}

	@Test("Negative random source produces negative offset")
	func points_negativeRandomSourceProducesNegativeOffset() {
		let sut = RandomCursorPatternStrategy(radius: 5, randomSource: { -1.0 })
		let origin = CGPoint(x: 100, y: 100)

		let result = sut.points(from: origin)

		#expect(result == [CGPoint(x: 95, y: 95)])
	}
}
