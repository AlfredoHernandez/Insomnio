//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import Foundation

final class TimerSchedulerPreviewStub: TimerScheduler {
	func schedule(interval _: TimeInterval, repeats _: Bool, block _: @escaping @MainActor () -> Void) -> TimerCancellable {
		Cancellable()
	}

	private final class Cancellable: TimerCancellable {
		func invalidate() {}
	}
}
#endif
