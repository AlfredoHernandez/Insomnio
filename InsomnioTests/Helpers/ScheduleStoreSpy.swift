//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class ScheduleStoreSpy: ScheduleStore {
	enum ReceivedMessage: Equatable {
		case loadRules
		case saveRules
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedRules: [ScheduleRule] = []

	func loadRules() -> [ScheduleRule] {
		receivedMessages.append(.loadRules)
		return stubbedRules
	}

	func saveRules(_ rules: [ScheduleRule]) {
		receivedMessages.append(.saveRules)
		stubbedRules = rules
	}
}
