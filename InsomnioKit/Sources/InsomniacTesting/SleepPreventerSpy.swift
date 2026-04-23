//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac

public final class SleepPreventerSpy: SleepPreventer {
	public enum ReceivedMessage: Equatable {
		case createAssertion
		case releaseAssertion
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public var stubbedCreateResult = true

	public init() {}

	public func createAssertion() -> Bool {
		receivedMessages.append(.createAssertion)
		return stubbedCreateResult
	}

	public func releaseAssertion() {
		receivedMessages.append(.releaseAssertion)
	}
}
