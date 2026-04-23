//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import Insomniac

public final class IdleTimeProviderSpy: IdleTimeProvider {
	public enum ReceivedMessage: Equatable {
		case secondsSinceLastUserInput
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public var stubbedIdleTime: TimeInterval = 0

	public init() {}

	public func secondsSinceLastUserInput() -> TimeInterval {
		receivedMessages.append(.secondsSinceLastUserInput)
		return stubbedIdleTime
	}
}
