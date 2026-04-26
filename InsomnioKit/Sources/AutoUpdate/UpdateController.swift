//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Triggers app self-update flows.
///
/// The protocol exists so the composition root can swap the production
/// Sparkle-backed implementation for a stub in previews and tests.
public protocol UpdateController: AnyObject {
	/// Whether the underlying updater is allowed to check on a schedule.
	/// Bound to a user-facing toggle in Settings.
	var automaticallyChecksForUpdates: Bool { get set }

	/// Whether `checkForUpdates()` is currently safe to call. Sparkle returns
	/// `false` while a check is in progress.
	var canCheckForUpdates: Bool { get }

	/// User-initiated check. Surfaces Sparkle's standard UI (no available
	/// update / download / install) when invoked.
	func checkForUpdates()
}
