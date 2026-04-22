//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
final class SleepPreventerPreviewStub: SleepPreventer {
	func createAssertion() -> Bool {
		true
	}

	func releaseAssertion() {}
}
#endif
