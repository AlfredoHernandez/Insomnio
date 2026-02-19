//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

class TimerCancellableStub: TimerCancellable {
	func invalidate() {}
}

class TimerSchedulerStub: TimerScheduler {
	func schedule(interval _: TimeInterval, repeats _: Bool, block _: @escaping () -> Void) -> TimerCancellable {
		TimerCancellableStub()
	}
}
