//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio

@MainActor
final class PowerSourceProviderSpy: PowerSourceProvider {
	enum ReceivedMessage: Equatable {
		case isOnBatteryPower
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedIsOnBattery = false

	func isOnBatteryPower() -> Bool {
		receivedMessages.append(.isOnBatteryPower)
		return stubbedIsOnBattery
	}
}
