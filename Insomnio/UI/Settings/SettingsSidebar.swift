//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct SettingsSidebar: View {
	@Binding var selection: SettingsDestination?

	var body: some View {
		List(selection: $selection) {
			Section {
				ForEach(SettingsDestination.allCases, id: \.self) { destination in
					Label(destination.title, systemImage: destination.systemImage)
						.tag(destination as SettingsDestination?)
				}
			}
		}
		.listStyle(.sidebar)
	}
}

#Preview {
	@Previewable @State var selection: SettingsDestination? = .keepAwake
	SettingsSidebar(selection: $selection)
}
