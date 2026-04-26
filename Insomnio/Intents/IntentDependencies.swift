//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

/// Process-wide hand-off from `AppDependencies.create()` to the App Intent types.
///
/// App Intents are instantiated by the system (Shortcuts, Spotlight, Siri) and
/// cannot receive constructor arguments, so they resolve their collaborators
/// through this static entry point. `AppCoordinator.start()` is responsible
/// for assigning `performer` before any intent can run.
@MainActor
enum IntentDependencies {
	static var performer: (any InsomnioIntentPerformer)?
}
