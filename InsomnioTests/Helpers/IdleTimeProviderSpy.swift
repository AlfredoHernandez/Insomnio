//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Foundation

@MainActor
final class IdleTimeProviderSpy: IdleTimeProvider {
	enum ReceivedMessage: Equatable {
		case secondsSinceLastUserInput
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedIdleTime: TimeInterval = 0

	func secondsSinceLastUserInput() -> TimeInterval {
		receivedMessages.append(.secondsSinceLastUserInput)
		return stubbedIdleTime
	}
}
