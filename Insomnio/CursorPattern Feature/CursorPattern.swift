//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

protocol CursorPatternStrategy: Sendable {
	nonisolated func points(from origin: CGPoint) -> [CGPoint]
}

nonisolated enum CursorPattern: CaseIterable, Hashable {
	case nudge
	case circle
	case zigzag
	case random

	private static let nudgeStrategy: any CursorPatternStrategy = NudgeCursorPatternStrategy()
	private static let circleStrategy: any CursorPatternStrategy = CircleCursorPatternStrategy()
	private static let zigzagStrategy: any CursorPatternStrategy = ZigzagCursorPatternStrategy()
	private static let randomStrategy: any CursorPatternStrategy = RandomCursorPatternStrategy()

	var strategy: any CursorPatternStrategy {
		switch self {
		case .nudge: Self.nudgeStrategy

		case .circle: Self.circleStrategy

		case .zigzag: Self.zigzagStrategy

		case .random: Self.randomStrategy
		}
	}
}
