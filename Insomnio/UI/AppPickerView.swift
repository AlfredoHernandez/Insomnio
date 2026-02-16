//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct AppPickerView: View {
	let onSelect: (String, String) -> Void
	let onCancel: () -> Void
	@State private var searchText = ""

	private var runningApps: [(bundleID: String, name: String, icon: NSImage)] {
		NSWorkspace.shared.runningApplications
			.filter { $0.activationPolicy == .regular }
			.compactMap { app in
				guard let bundleID = app.bundleIdentifier else { return nil }
				let name = app.localizedName ?? bundleID
				let icon = app.icon ?? NSImage(systemSymbolName: "app", accessibilityDescription: nil) ?? NSImage()
				return (bundleID, name, icon)
			}
			.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
			.sorted { $0.name < $1.name }
	}

	var body: some View {
		VStack(spacing: 12) {
			Text("apprules_picker_title")
				.font(.headline)

			TextField("apprules_picker_search", text: $searchText)
				.textFieldStyle(.roundedBorder)

			List(runningApps, id: \.bundleID) { app in
				Button {
					onSelect(app.bundleID, app.name)
				} label: {
					HStack {
						Image(nsImage: app.icon)
							.resizable()
							.frame(width: 24, height: 24)
						VStack(alignment: .leading) {
							Text(app.name)
								.font(.subheadline)
							Text(app.bundleID)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
				}
				.buttonStyle(.plain)
			}
			.frame(height: 300)

			Button("apprules_picker_cancel", action: onCancel)
				.buttonStyle(.plain)
				.font(.caption)
		}
		.padding(20)
		.frame(width: 360)
	}
}
