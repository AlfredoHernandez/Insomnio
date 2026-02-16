//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

protocol CursorPatternStrategy {
	func points(from origin: CGPoint) -> [CGPoint]
}

enum CursorPattern: CaseIterable, Hashable {
	case nudge
	case circle
	case zigzag
	case random

	private static let nudgeStrategy: CursorPatternStrategy = NudgeCursorPatternStrategy()
	private static let circleStrategy: CursorPatternStrategy = CircleCursorPatternStrategy()
	private static let zigzagStrategy: CursorPatternStrategy = ZigzagCursorPatternStrategy()
	private static let randomStrategy: CursorPatternStrategy = RandomCursorPatternStrategy()

	var strategy: CursorPatternStrategy {
		switch self {
		case .nudge: Self.nudgeStrategy

		case .circle: Self.circleStrategy

		case .zigzag: Self.zigzagStrategy

		case .random: Self.randomStrategy
		}
	}

	var isFree: Bool {
		self == .nudge
	}
}
