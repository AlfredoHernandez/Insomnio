//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

public protocol RuleStore<Rule> {
	associatedtype Rule: Codable
	func loadRules() -> [Rule]
	func saveRules(_ rules: [Rule])
}
