//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class TimerCancellablePreviewStub: TimerCancellable {
	func invalidate() {}
}

final class TimerSchedulerPreviewStub: TimerScheduler {
	func schedule(interval _: TimeInterval, repeats _: Bool, block _: @escaping () -> Void) -> TimerCancellable {
		TimerCancellablePreviewStub()
	}
}
