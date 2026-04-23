//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import Insomniac

final class SleepPreventerPreviewStub: SleepPreventer {
	func createAssertion() -> Bool {
		true
	}

	func releaseAssertion() {}
}
#endif
