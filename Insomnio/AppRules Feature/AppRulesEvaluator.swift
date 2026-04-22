//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol AppRulesEvaluator: AnyObject {
	var rules: [AppRule] { get }
	func shouldBeActive() -> Bool
	func addRule(_ rule: AppRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: AppRule)
}
