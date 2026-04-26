//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum InsomnioIntentError: Error, LocalizedError {
	case performerUnavailable

	var errorDescription: String? {
		switch self {
		case .performerUnavailable:
			String(localized: "intent_error_performer_unavailable")
		}
	}
}
