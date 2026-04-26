//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Schedule
import SwiftUI

struct ScheduleSection: View {
	let scheduleEvaluator: any ScheduleEvaluator
	@State private var isAddingRule = false

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					liquidGlassSectionTitle("schedule_title", systemImage: "calendar.badge.clock")
					Spacer()
					Button { isAddingRule = true } label: {
						Image(systemName: "plus.circle")
					}
					.liquidGlassIconButton()
				}

				Text("schedule_desc")
					.font(LiquidGlassStyle.sectionBodyFont)
					.foregroundStyle(LiquidGlassStyle.sectionHintStyle)

				if scheduleEvaluator.rules.isEmpty {
					Text("schedule_empty")
						.font(LiquidGlassStyle.sectionBodyFont)
						.foregroundStyle(LiquidGlassStyle.sectionBodyStyle)
						.padding(.vertical, 4)
				} else {
					ForEach(scheduleEvaluator.rules) { rule in
						ScheduleRuleRow(
							rule: rule,
							onUpdate: { scheduleEvaluator.updateRule($0) },
							onDelete: { scheduleEvaluator.removeRule(id: $0) },
						)
					}
				}
			}
		}
		.sheet(isPresented: $isAddingRule) {
			ScheduleRuleEditor(
				rule: ScheduleRule(),
				onSave: { rule in
					scheduleEvaluator.addRule(rule)
					isAddingRule = false
				},
				onCancel: { isAddingRule = false },
			)
		}
	}
}

// MARK: - ScheduleRuleRow

private struct ScheduleRuleRow: View {
	let rule: ScheduleRule
	let onUpdate: (ScheduleRule) -> Void
	let onDelete: (UUID) -> Void

	var body: some View {
		HStack(spacing: 8) {
			VStack(alignment: .leading, spacing: 2) {
				Text(weekdayText)
					.font(.system(size: 11, weight: .medium))
				Text(timeRangeText)
					.font(.system(size: 11))
					.foregroundStyle(.secondary)
			}

			Spacer()

			Toggle("", isOn: Binding(
				get: { rule.isEnabled },
				set: { newValue in
					var updated = rule
					updated.isEnabled = newValue
					onUpdate(updated)
				},
			))
			.toggleStyle(.switch)
			.controlSize(.mini)
			.labelsHidden()

			Button {
				onDelete(rule.id)
			} label: {
				Image(systemName: "minus.circle.fill")
					.foregroundStyle(.red)
			}
			.buttonStyle(.plain)
		}
		.padding(.vertical, 2)
	}

	private var weekdayText: String {
		rule.weekdays.sorted().map(\.shortLabel).joined(separator: " ")
	}

	private var timeRangeText: String {
		let start = dateFrom(hour: rule.startHour, minute: rule.startMinute)
		let end = dateFrom(hour: rule.endHour, minute: rule.endMinute)
		let format = Date.FormatStyle(date: .omitted, time: .shortened)
		return "\(start.formatted(format)) – \(end.formatted(format))"
	}
}

private func dateFrom(hour: Int, minute: Int) -> Date {
	var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
	components.hour = hour
	components.minute = minute
	return Calendar.current.date(from: components) ?? Date()
}

// MARK: - ScheduleRuleEditor

private struct ScheduleRuleEditor: View {
	@State var rule: ScheduleRule
	let onSave: (ScheduleRule) -> Void
	let onCancel: () -> Void

	@State private var startTime = Date()
	@State private var endTime = Date()

	var body: some View {
		VStack(spacing: 16) {
			Text("schedule_add_title")
				.font(.headline)

			VStack(alignment: .leading, spacing: 8) {
				Text("schedule_days")
					.font(.subheadline)

				HStack(spacing: 4) {
					ForEach(Weekday.allCases, id: \.rawValue) { day in
						WeekdayButton(
							day: day,
							isSelected: rule.weekdays.contains(day),
							onToggle: {
								if rule.weekdays.contains(day) {
									rule.weekdays.remove(day)
								} else {
									rule.weekdays.insert(day)
								}
							},
						)
					}
				}
			}

			HStack {
				VStack(alignment: .leading) {
					Text("schedule_start_time")
						.font(.subheadline)
					DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
				}
				Spacer()
				VStack(alignment: .leading) {
					Text("schedule_end_time")
						.font(.subheadline)
					DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
				}
			}

			HStack {
				Button("schedule_cancel", action: onCancel)
					.buttonStyle(.plain)

				Spacer()

				Button("schedule_save") {
					rule.startHour = Calendar.current.component(.hour, from: startTime)
					rule.startMinute = Calendar.current.component(.minute, from: startTime)
					rule.endHour = Calendar.current.component(.hour, from: endTime)
					rule.endMinute = Calendar.current.component(.minute, from: endTime)
					onSave(rule)
				}
				.buttonStyle(.borderedProminent)
				.disabled(rule.weekdays.isEmpty)
			}
		}
		.padding(20)
		.frame(width: 320)
		.onAppear {
			startTime = dateFrom(hour: rule.startHour, minute: rule.startMinute)
			endTime = dateFrom(hour: rule.endHour, minute: rule.endMinute)
		}
	}
}

// MARK: - WeekdayButton

private struct WeekdayButton: View {
	let day: Weekday
	let isSelected: Bool
	let onToggle: () -> Void

	var body: some View {
		Button(action: onToggle) {
			Text(day.shortLabel)
				.font(.system(size: 11, weight: .medium))
				.frame(width: 28, height: 28)
				.background(isSelected ? Color.accentColor : Color.clear)
				.foregroundStyle(isSelected ? .white : .primary)
				.clipShape(Circle())
				.overlay(Circle().stroke(.secondary.opacity(0.3), lineWidth: 1))
		}
		.buttonStyle(.plain)
	}
}
