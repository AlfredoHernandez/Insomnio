//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Sparkle

/// Sparkle-backed `UpdateController`.
///
/// Wraps `SPUStandardUpdaterController`, which owns Sparkle's lifecycle and
/// presents the standard updater UI (available/no update sheets, scheduled
/// check timer, error reporting). Configuration lives in `Info.plist`:
/// `SUFeedURL`, `SUPublicEDKey`, optionally `SUEnableAutomaticChecks`.
public final class SparkleUpdateController: UpdateController {
	private let controller: SPUStandardUpdaterController

	/// `startingUpdater` is `true` so Sparkle starts its scheduled-check
	/// timer immediately at app launch (subject to the user's preference
	/// exposed by `automaticallyChecksForUpdates`). No delegates are needed
	/// for the default flow — Sparkle reads everything from `Info.plist`.
	public init() {
		controller = SPUStandardUpdaterController(
			startingUpdater: true,
			updaterDelegate: nil,
			userDriverDelegate: nil,
		)
	}

	public var automaticallyChecksForUpdates: Bool {
		get { controller.updater.automaticallyChecksForUpdates }
		set { controller.updater.automaticallyChecksForUpdates = newValue }
	}

	public var canCheckForUpdates: Bool {
		controller.updater.canCheckForUpdates
	}

	public func checkForUpdates() {
		// `sender` is unused by Sparkle's internal handler but `@objc` action
		// signatures still require a non-nil object; pass NSApp.
		controller.checkForUpdates(NSApp)
	}
}
