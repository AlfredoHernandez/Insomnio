//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppIntents
import AutoStop

enum AutoStopDurationAppEnum: String, AppEnum {
	case thirtyMinutes
	case oneHour
	case twoHours
	case fourHours

	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Auto-Stop Duration"

	static let caseDisplayRepresentations: [AutoStopDurationAppEnum: DisplayRepresentation] = [
		.thirtyMinutes: "30 Minutes",
		.oneHour: "1 Hour",
		.twoHours: "2 Hours",
		.fourHours: "4 Hours",
	]

	var domainValue: AutoStopDuration {
		switch self {
		case .thirtyMinutes: .thirtyMinutes
		case .oneHour: .oneHour
		case .twoHours: .twoHours
		case .fourHours: .fourHours
		}
	}
}
