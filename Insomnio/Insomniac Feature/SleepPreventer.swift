//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

protocol SleepPreventer {
	func createAssertion() -> Bool
	func releaseAssertion()
}
