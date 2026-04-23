//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol AppRulesEvaluating: AnyObject {
	func shouldBeActive() -> Bool
}

public protocol AppRulesEvaluator: AppRulesEvaluating {
	var rules: [AppRule] { get }
	func addRule(_ rule: AppRule)
	func removeRule(id: UUID)
	func updateRule(_ rule: AppRule)
}
