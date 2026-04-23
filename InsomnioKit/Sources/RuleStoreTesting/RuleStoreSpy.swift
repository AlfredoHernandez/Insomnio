//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import RuleStore

public final class RuleStoreSpy<Rule: Codable>: RuleStore {
	public enum ReceivedMessage: Equatable {
		case loadRules
		case saveRules
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public var stubbedRules: [Rule] = []

	public init() {}

	public func loadRules() -> [Rule] {
		receivedMessages.append(.loadRules)
		return stubbedRules
	}

	public func saveRules(_ rules: [Rule]) {
		receivedMessages.append(.saveRules)
		stubbedRules = rules
	}
}
