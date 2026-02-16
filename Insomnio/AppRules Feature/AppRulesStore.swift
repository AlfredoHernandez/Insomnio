//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol AppRulesStore {
	func loadRules() -> [AppRule]
	func saveRules(_ rules: [AppRule])
}
