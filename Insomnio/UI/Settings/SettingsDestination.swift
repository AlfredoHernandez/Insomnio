//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

enum SettingsDestination: String, Hashable, CaseIterable {
	case dashboard
	case status
	case keepAwake
	case automation
	case general

	var title: LocalizedStringKey {
		switch self {
		case .dashboard: "settings_sidebar_dashboard"
		case .status: "settings_sidebar_status"
		case .keepAwake: "settings_sidebar_keep_awake"
		case .automation: "settings_sidebar_automation"
		case .general: "settings_sidebar_general"
		}
	}

	var systemImage: String {
		switch self {
		case .dashboard: "rectangle.grid.2x2"
		case .status: "moon.zzz"
		case .keepAwake: "cursorarrow.motionlines"
		case .automation: "gearshape.2"
		case .general: "slider.horizontal.3"
		}
	}
}
