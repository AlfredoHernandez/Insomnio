//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class AppRulesStoreSpy: AppRulesStore {
	enum ReceivedMessage: Equatable {
		case loadRules
		case saveRules
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedRules: [AppRule] = []

	func loadRules() -> [AppRule] {
		receivedMessages.append(.loadRules)
		return stubbedRules
	}

	func saveRules(_ rules: [AppRule]) {
		receivedMessages.append(.saveRules)
		stubbedRules = rules
	}
}
