//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol ScheduleStore {
	func loadRules() -> [ScheduleRule]
	func saveRules(_ rules: [ScheduleRule])
}
