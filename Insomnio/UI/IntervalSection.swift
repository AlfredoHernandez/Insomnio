//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct IntervalSection: View {
	@Binding var interval: TimeInterval
	let isDisabled: Bool

	private static let tickMarks: [(label: LocalizedStringKey, seconds: TimeInterval)] = [
		("tick_5sec", 5),
		("tick_1min", 60),
		("tick_5min", 300),
		("tick_1hour", 3600),
		("tick_5hours", 18000),
		("tick_24hours", 86400),
	]

	private static let minSeconds: TimeInterval = 5
	private static let maxSeconds: TimeInterval = 86400

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("interval_label \(formattedInterval)")
				.font(.subheadline)
				.foregroundStyle(.secondary)

			Slider(
				value: Binding(
					get: { secondsToSlider(interval) },
					set: { interval = sliderToSeconds($0) },
				),
				in: 0 ... 1,
			)

			HStack {
				ForEach(Array(Self.tickMarks.enumerated()), id: \.offset) { _, tick in
					Text(tick.label)
						.font(.caption2)
						.foregroundStyle(.tertiary)
					if tick.seconds != Self.maxSeconds {
						Spacer()
					}
				}
			}
		}
		.disabled(isDisabled)
	}

	// MARK: - Helpers

	private var formattedInterval: String {
		let seconds = interval
		if seconds < 60 {
			let value = Int(round(seconds))
			return value == 1
				? String(localized: "time_1_second")
				: String(localized: "time_n_seconds \(value)")
		} else if seconds < 3600 {
			let value = Int(round(seconds / 60))
			return value == 1
				? String(localized: "time_1_minute")
				: String(localized: "time_n_minutes \(value)")
		} else {
			let value = round(seconds / 3600 * 10) / 10
			if value == 1 {
				return String(localized: "time_1_hour")
			} else if value == value.rounded(.down) {
				return String(localized: "time_n_hours \(Int(value))")
			} else {
				return String(localized: "time_decimal_hours \(value)")
			}
		}
	}

	private func secondsToSlider(_ seconds: TimeInterval) -> Double {
		let clamped = min(max(seconds, Self.minSeconds), Self.maxSeconds)
		return log(clamped / Self.minSeconds) / log(Self.maxSeconds / Self.minSeconds)
	}

	private func sliderToSeconds(_ value: Double) -> TimeInterval {
		Self.minSeconds * pow(Self.maxSeconds / Self.minSeconds, value)
	}
}
