//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

class SleepPreventerStub: SleepPreventer {
	func createAssertion() -> Bool {
		true
	}

	func releaseAssertion() {}
}
