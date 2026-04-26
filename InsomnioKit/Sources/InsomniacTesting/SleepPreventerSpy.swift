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
	private var isHolding = false

	public init() {}

	public func createAssertion() -> Bool {
		// Mirror `IOKitSleepPreventer`: a duplicate `createAssertion` while
		// already holding is a no-op and is not recorded.
		guard !isHolding else { return true }
		receivedMessages.append(.createAssertion)
		isHolding = stubbedCreateResult
		return stubbedCreateResult
	}

	public func releaseAssertion() {
		// Mirror `IOKitSleepPreventer`: releasing without an active assertion
		// is a no-op and is not recorded.
		guard isHolding else { return }
		receivedMessages.append(.releaseAssertion)
		isHolding = false
	}
}
