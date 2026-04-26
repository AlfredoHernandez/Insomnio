//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Charts
import Insomniac
import SwiftUI

/// Dashboard card showing hourly activation trend for the last 24h plus the
/// most recent sessions. Uses Swift Charts for the sparkline.
struct RecentActivityCard: View {
	let events: [ActivationEvent]
	let isActive: Bool
	let now: Date

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 12) {
				liquidGlassSectionTitle("recent_activity_title", systemImage: "chart.bar.xaxis")

				if events.isEmpty {
					emptyState
				} else {
					chart
					if !lastEvents.isEmpty {
						Divider().opacity(0.4)
						lastEventList
					}
				}
			}
		}
	}

	private var emptyState: some View {
		Text("recent_activity_empty")
			.font(LiquidGlassStyle.sectionBodyFont)
			.foregroundStyle(.secondary)
			.padding(.vertical, 8)
	}

	private var chart: some View {
		Chart(buckets) { bucket in
			BarMark(
				x: .value("Hour", bucket.hour, unit: .hour),
				y: .value("Active minutes", bucket.activeMinutes),
				width: .ratio(0.65),
			)
			.foregroundStyle(
				LinearGradient(
					colors: [.green.opacity(0.95), .green.opacity(0.55)],
					startPoint: .top,
					endPoint: .bottom,
				),
			)
			.clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
		}
		.chartYAxis(.hidden)
		.chartXAxis {
			AxisMarks(values: .stride(by: .hour, count: 6)) { _ in
				AxisValueLabel(format: .dateTime.hour())
					.font(.system(size: 9))
					.foregroundStyle(.secondary)
			}
		}
		.frame(height: 72)
	}

	private var lastEventList: some View {
		VStack(alignment: .leading, spacing: 6) {
			ForEach(lastEvents) { event in
				HStack(spacing: 10) {
					Text(event.startDate.formatted(date: .omitted, time: .shortened))
						.font(.system(size: 11, weight: .medium, design: .rounded))
						.monospacedDigit()
						.foregroundStyle(.primary)
						.frame(width: 58, alignment: .leading)

					Text(event.source.titleKey)
						.font(.system(size: 11))
						.foregroundStyle(.secondary)

					Spacer()

					Text(durationLabel(for: event))
						.font(.system(size: 11, weight: .medium, design: .rounded))
						.monospacedDigit()
						.foregroundStyle(.secondary)
				}
			}
		}
	}

	// MARK: - Derived data

	private var lastEvents: [ActivationEvent] {
		Array(events.reversed().prefix(3))
	}

	private var buckets: [HourlyBucket] {
		let calendar = Calendar.current
		let startOfHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
		let windowStart = calendar.date(byAdding: .hour, value: -23, to: startOfHour) ?? now

		var bins: [Date: TimeInterval] = [:]
		for hourOffset in 0 ..< 24 {
			if let hour = calendar.date(byAdding: .hour, value: hourOffset, to: windowStart) {
				bins[hour] = 0
			}
		}

		let windowEnd = calendar.date(byAdding: .hour, value: 1, to: startOfHour) ?? now
		for event in events {
			let effectiveEnd = event.endDate ?? (isActive ? now : event.startDate)
			var cursor = max(event.startDate, windowStart)
			let end = min(effectiveEnd, windowEnd)
			while cursor < end {
				guard let bucket = calendar.dateInterval(of: .hour, for: cursor) else { break }
				let chunkEnd = min(bucket.end, end)
				let minutes = chunkEnd.timeIntervalSince(cursor) / 60
				bins[bucket.start, default: 0] += minutes
				cursor = chunkEnd
			}
		}

		return bins
			.map { HourlyBucket(hour: $0.key, activeMinutes: $0.value) }
			.sorted { $0.hour < $1.hour }
	}

	private func durationLabel(for event: ActivationEvent) -> String {
		let seconds = event.duration ?? now.timeIntervalSince(event.startDate)
		if seconds < 60 {
			return String(localized: "duration_less_than_minute")
		}
		return Duration.seconds(seconds)
			.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
	}
}

private struct HourlyBucket: Identifiable {
	let hour: Date
	let activeMinutes: TimeInterval
	var id: Date {
		hour
	}
}

#Preview("With data") {
	let now = Date()
	let calendar = Calendar.current
	let events = [
		ActivationEvent(
			startDate: calendar.date(byAdding: .hour, value: -18, to: now)!,
			endDate: calendar.date(byAdding: .hour, value: -17, to: now),
			source: .menuBar,
		),
		ActivationEvent(
			startDate: calendar.date(byAdding: .hour, value: -6, to: now)!,
			endDate: calendar.date(byAdding: .minute, value: -120, to: now),
			source: .mainWindow,
		),
		ActivationEvent(
			startDate: calendar.date(byAdding: .minute, value: -40, to: now)!,
			endDate: nil,
			source: .globalShortcut,
		),
	]
	return RecentActivityCard(events: events, isActive: true, now: now)
		.padding()
		.frame(width: 640)
}

#Preview("Empty") {
	RecentActivityCard(events: [], isActive: false, now: .now)
		.padding()
		.frame(width: 640)
}
