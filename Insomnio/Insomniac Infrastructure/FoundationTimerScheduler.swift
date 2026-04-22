//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class FoundationTimerScheduler: TimerScheduler {
	func schedule(interval: TimeInterval, repeats: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable {
		Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { _ in
			MainActor.assumeIsolated {
				block()
			}
		}
	}
}
