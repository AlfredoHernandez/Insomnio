//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class FoundationTimerScheduler: TimerScheduler {
	public init() {}

	public func schedule(interval: TimeInterval, repeats: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable {
		// Register the timer in `.common` modes so it keeps firing while the user
		// is tracking UI (menu open, popover visible, control drag). Callers are
		// required to invoke `schedule` from the MainActor (enforced by default
		// isolation), so the fire closure always runs on the main thread;
		// `MainActor.assumeIsolated` bridges that runtime guarantee to the
		// `@MainActor` isolation the `block` signature requires.
		let timer = Timer(timeInterval: interval, repeats: repeats) { _ in
			MainActor.assumeIsolated {
				block()
			}
		}
		RunLoop.main.add(timer, forMode: .common)
		return timer
	}
}
