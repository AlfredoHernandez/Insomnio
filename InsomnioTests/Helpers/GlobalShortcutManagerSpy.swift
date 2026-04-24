//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Shortcut

final class GlobalShortcutManagerSpy: GlobalShortcutManager {
	enum ReceivedMessage: Equatable {
		case registerShortcut
		case unregisterShortcut
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	private(set) var registeredAction: (() -> Void)?

	func registerShortcut(action: @escaping () -> Void) {
		receivedMessages.append(.registerShortcut)
		registeredAction = action
	}

	func unregisterShortcut() {
		receivedMessages.append(.unregisterShortcut)
		registeredAction = nil
	}
}
