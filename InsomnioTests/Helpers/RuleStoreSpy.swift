//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import RuleStore

@MainActor
final class RuleStoreSpy<Rule: Codable>: RuleStore {
	enum ReceivedMessage: Equatable {
		case loadRules
		case saveRules
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedRules: [Rule] = []

	func loadRules() -> [Rule] {
		receivedMessages.append(.loadRules)
		return stubbedRules
	}

	func saveRules(_ rules: [Rule]) {
		receivedMessages.append(.saveRules)
		stubbedRules = rules
	}
}
