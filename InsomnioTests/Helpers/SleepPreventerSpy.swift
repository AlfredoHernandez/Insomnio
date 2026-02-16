//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class SleepPreventerSpy: SleepPreventer {
	enum ReceivedMessage: Equatable {
		case createAssertion
		case releaseAssertion
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedCreateResult = true

	func createAssertion() -> Bool {
		receivedMessages.append(.createAssertion)
		return stubbedCreateResult
	}

	func releaseAssertion() {
		receivedMessages.append(.releaseAssertion)
	}
}
