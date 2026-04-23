//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Polls `condition` until it returns `true` or `timeout` elapses, yielding
/// between checks so the event loop can advance unstructured tasks scheduled
/// during the same test.
@MainActor
public func waitUntil(
	timeout: Duration = .seconds(1),
	pollInterval: Duration = .milliseconds(10),
	_ condition: () -> Bool,
) async {
	let start = ContinuousClock.now
	while !condition(), ContinuousClock.now - start < timeout {
		await Task.yield()
		try? await Task.sleep(for: pollInterval)
	}
}
