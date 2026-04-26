//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import Automation

final class AutomationCoordinatingSpy: AutomationCoordinating {
	enum ReceivedMessage: Equatable {
		case startMonitoring
		case stopMonitoring
	}

	private(set) var receivedMessages = [ReceivedMessage]()

	func startMonitoring() {
		receivedMessages.append(.startMonitoring)
	}

	func stopMonitoring() {
		receivedMessages.append(.stopMonitoring)
	}
}
