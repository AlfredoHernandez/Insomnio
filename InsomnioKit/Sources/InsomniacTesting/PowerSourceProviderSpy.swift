//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Insomniac

public final class PowerSourceProviderSpy: PowerSourceProvider {
	public enum ReceivedMessage: Equatable {
		case isOnBatteryPower
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public var stubbedIsOnBattery = false

	public init() {}

	public func isOnBatteryPower() -> Bool {
		receivedMessages.append(.isOnBatteryPower)
		return stubbedIsOnBattery
	}
}
