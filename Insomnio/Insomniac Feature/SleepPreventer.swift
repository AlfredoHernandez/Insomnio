//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol SleepPreventer {
	@discardableResult
	func createAssertion() -> Bool
	func releaseAssertion()
}
