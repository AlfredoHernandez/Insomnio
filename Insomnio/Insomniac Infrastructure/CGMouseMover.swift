//
// Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import CoreGraphics

struct CGMouseMover: MouseMover {
    func moveMouseTo(_ point: CGPoint) -> Bool {
        CGWarpMouseCursorPosition(point) == .success
    }

    func currentMouseLocation() -> CGPoint {
        let location = NSEvent.mouseLocation
        guard let screenHeight = NSScreen.main?.frame.height else {
            return .zero
        }
        return CGPoint(x: location.x, y: screenHeight - location.y)
    }
}
