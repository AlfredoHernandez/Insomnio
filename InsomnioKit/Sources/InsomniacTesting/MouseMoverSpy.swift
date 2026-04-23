//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics
import Insomniac

public final class MouseMoverSpy: MouseMover {
	public enum ReceivedMessage: Equatable {
		case moveTo(CGPoint)
		case currentLocation
	}

	public private(set) var receivedMessages = [ReceivedMessage]()
	public var stubbedLocation: CGPoint = .init(x: 100, y: 100)

	public init() {}

	public func moveMouseTo(_ point: CGPoint) -> Bool {
		receivedMessages.append(.moveTo(point))
		return true
	}

	public func currentMouseLocation() -> CGPoint {
		receivedMessages.append(.currentLocation)
		return stubbedLocation
	}
}
