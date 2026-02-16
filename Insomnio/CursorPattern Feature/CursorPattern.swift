//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics
import SwiftUI

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

	var label: LocalizedStringKey {
		switch self {
		case .nudge: "pattern_nudge"

		case .circle: "pattern_circle"

		case .zigzag: "pattern_zigzag"

		case .random: "pattern_random"
		}
	}

	var description: LocalizedStringKey {
		switch self {
		case .nudge: "pattern_nudge_desc"

		case .circle: "pattern_circle_desc"

		case .zigzag: "pattern_zigzag_desc"

		case .random: "pattern_random_desc"
		}
	}

	var icon: String {
		switch self {
		case .nudge: "arrow.right.and.line.vertical.and.arrow.left"

		case .circle: "arrow.trianglehead.2.clockwise"

		case .zigzag: "point.bottomleft.forward.to.point.topright.scurvepath"

		case .random: "dice"
		}
	}

	var isFree: Bool {
		self == .nudge
	}
}
