//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AutoStop

/// Entry point that App Intents dispatch user-visible actions through.
///
/// Intent types live in the app binary (App Intents discovery scans the app binary,
/// not the Swift package), so the protocol is declared here rather than in `InsomnioKit`.
/// Keeping the protocol at this layer also lets unit tests cover intent-level behavior
/// without instantiating `AppIntent` types, which are awkward to exercise directly.
@MainActor
protocol InsomnioIntentPerformer {
	func start()
	func stop()
	func toggle()
	func startForDuration(_ duration: AutoStopDuration)
}
