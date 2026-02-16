//
// Copyright © 2026 Jesus Alfredo Hernandez Alarcon. All rights reserved.
//

import CoreGraphics
@testable import Insomnio

@MainActor
final class MouseMoverSpy: MouseMover {
    enum ReceivedMessage: Equatable {
        case moveTo(CGPoint)
        case currentLocation
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    var stubbedLocation: CGPoint = CGPoint(x: 100, y: 100)

    func moveMouseTo(_ point: CGPoint) -> Bool {
        receivedMessages.append(.moveTo(point))
        return true
    }

    func currentMouseLocation() -> CGPoint {
        receivedMessages.append(.currentLocation)
        return stubbedLocation
    }
}
