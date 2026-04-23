//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol TimerCancellable {
	func invalidate()
}

extension Timer: TimerCancellable {}

public protocol TimerScheduler {
	func schedule(interval: TimeInterval, repeats: Bool, block: @escaping @MainActor () -> Void) -> TimerCancellable
}
