//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import CoreGraphics

@MainActor
final class MouseMoverSpy: MouseMover {
	enum ReceivedMessage: Equatable {
		case moveTo(CGPoint)
		case currentLocation
	}

	private(set) var receivedMessages = [ReceivedMessage]()
	var stubbedLocation: CGPoint = .init(x: 100, y: 100)

	func moveMouseTo(_ point: CGPoint) -> Bool {
		receivedMessages.append(.moveTo(point))
		return true
	}

	func currentMouseLocation() -> CGPoint {
		receivedMessages.append(.currentLocation)
		return stubbedLocation
	}
}
