//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct AppRulesSection: View {
	let appRulesEvaluator: any AppRulesEvaluator
	@State private var showingAppPicker = false

	var body: some View {
		CardView {
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Label("apprules_title", systemImage: "app.badge")
						.font(.subheadline.bold())
					Spacer()
					Button { showingAppPicker = true } label: {
						Image(systemName: "plus.circle")
					}
					.buttonStyle(.plain)
				}

				Text("apprules_desc")
					.font(.system(size: 11))
					.foregroundStyle(.tertiary)

				if appRulesEvaluator.rules.isEmpty {
					Text("apprules_empty")
						.font(.system(size: 11))
						.foregroundStyle(.secondary)
						.padding(.vertical, 4)
				} else {
					ForEach(appRulesEvaluator.rules) { rule in
						AppRuleRow(
							rule: rule,
							onToggle: { appRulesEvaluator.updateRule($0) },
							onDelete: { appRulesEvaluator.removeRule(id: $0) },
						)
					}
				}
			}
		}
		.sheet(isPresented: $showingAppPicker) {
			AppPickerView(
				onSelect: { bundleID, name in
					appRulesEvaluator.addRule(AppRule(bundleIdentifier: bundleID, displayName: name))
					showingAppPicker = false
				},
				onCancel: { showingAppPicker = false },
			)
		}
	}
}

// MARK: - AppRuleRow

private struct AppRuleRow: View {
	let rule: AppRule
	let onToggle: (AppRule) -> Void
	let onDelete: (UUID) -> Void

	var body: some View {
		HStack(spacing: 8) {
			VStack(alignment: .leading, spacing: 2) {
				Text(rule.displayName)
					.font(.system(size: 11, weight: .medium))
				Text(rule.bundleIdentifier)
					.font(.system(size: 10))
					.foregroundStyle(.secondary)
			}

			Spacer()

			Toggle("", isOn: Binding(
				get: { rule.isEnabled },
				set: { newValue in
					var updated = rule
					updated.isEnabled = newValue
					onToggle(updated)
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
}
