//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct AppPickerView: View {
	let availableApps: () -> [AppInfo]
	let onSelect: (String, String) -> Void
	let onCancel: () -> Void
	@State private var searchText = ""
	@State private var cachedApps: [AppInfo] = []

	private var filteredApps: [AppInfo] {
		cachedApps
			.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
			.sorted { $0.name < $1.name }
	}

	var body: some View {
		VStack(spacing: 12) {
			Text("apprules_picker_title")
				.font(.headline)

			TextField("apprules_picker_search", text: $searchText)
				.textFieldStyle(.roundedBorder)

			List(filteredApps) { app in
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
		.onAppear { cachedApps = availableApps() }
	}
}
