//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class FoundationTimerScheduler: TimerScheduler {
	public init() {}

	public func schedule(interval: TimeInterval, repeats: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable {
		// `Timer.scheduledTimer` fires on the run loop of the thread that scheduled
		// it. Callers are required to invoke `schedule` from the MainActor (enforced
		// by default isolation), so the timer's fire closure always runs on the main
		// thread. `MainActor.assumeIsolated` bridges that runtime guarantee to the
		// `@MainActor` isolation the `block` signature requires.
		Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { _ in
			MainActor.assumeIsolated {
				block()
			}
		}
	}
}
