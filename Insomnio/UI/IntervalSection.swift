//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct IntervalSection: View {
	@Binding var interval: TimeInterval
	let isDisabled: Bool

	private enum TimeUnit: CaseIterable {
		case seconds, minutes, hours

		var label: LocalizedStringKey {
			switch self {
			case .seconds: "unit_seconds"

			case .minutes: "unit_minutes"

			case .hours: "unit_hours"
			}
		}

		var divisor: TimeInterval {
			switch self {
			case .seconds: 1

			case .minutes: 60

			case .hours: 3600
			}
		}
	}

	private static let steps: [TimeInterval] = [
		5, 10, 15, 30, 60, 120, 300, 600, 900, 1800, 3600, 7200, 18000, 43200, 86400,
	]

	private static let tickLabels: [(label: LocalizedStringKey, index: Int)] = [
		("tick_5sec", 0),
		("tick_1min", 4),
		("tick_5min", 6),
		("tick_1hour", 10),
		("tick_5hours", 12),
		("tick_24hours", 14),
	]

	@State private var unit: TimeUnit = .seconds

	private var stepIndex: Binding<Double> {
		Binding(
			get: {
				let idx = Self.steps.enumerated()
					.min(by: { abs($0.element - interval) < abs($1.element - interval) })?
					.offset ?? 0
				return Double(idx)
			},
			set: {
				interval = Self.steps[Int(round($0))]
				unit = bestUnit(for: interval)
			},
		)
	}

	private var displayValue: Binding<Double> {
		Binding(
			get: { interval / unit.divisor },
			set: { interval = min(86400, max(5, $0 * unit.divisor)) },
		)
	}

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 4) {
				Text("interval_title")

				Text("interval_hint \(formattedInterval)")
					.foregroundStyle(.secondary)

				Slider(
					value: stepIndex,
					in: 0 ... Double(Self.steps.count - 1),
					step: 1,
				)

				GeometryReader { geo in
					let inset: CGFloat = 20
					let usableWidth = geo.size.width - 2 * inset
					let maxIndex = Double(Self.steps.count - 1)
					ForEach(Self.tickLabels, id: \.index) { tick in
						Text(tick.label)
							.font(.system(size: 10))
							.foregroundStyle(.tertiary)
							.fixedSize()
							.position(
								x: inset + usableWidth * Double(tick.index) / maxIndex,
								y: 6,
							)
					}
				}
				.frame(height: 14)

				HStack(spacing: 8) {
					Text("custom_interval_label")
						.font(.system(size: 11))
						.foregroundStyle(.secondary)

					TextField("", value: displayValue, format: .number)
						.textFieldStyle(.roundedBorder)
						.frame(width: 70)
						.monospacedDigit()
						.onSubmit { unit = bestUnit(for: interval) }

					Picker("", selection: $unit) {
						ForEach(TimeUnit.allCases, id: \.self) { u in
							Text(u.label).tag(u)
						}
					}
					.labelsHidden()
					.fixedSize()
				}
				.padding(.top, 4)
			}
			.disabled(isDisabled)
			.onAppear { unit = bestUnit(for: interval) }
		}
	}

	// MARK: - Helpers

	private func bestUnit(for seconds: TimeInterval) -> TimeUnit {
		if seconds >= 3600, seconds.truncatingRemainder(dividingBy: 3600) == 0 {
			return .hours
		} else if seconds >= 60, seconds.truncatingRemainder(dividingBy: 60) == 0 {
			return .minutes
		}
		return .seconds
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
}

#Preview {
	@Previewable @State var interval: TimeInterval = 30
	IntervalSection(interval: $interval, isDisabled: false)
		.padding()
		.frame(width: 420)
}
