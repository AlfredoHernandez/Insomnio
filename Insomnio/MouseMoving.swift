//
// Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

protocol MouseMoving {
    func moveMouseTo(_ point: CGPoint) -> Bool
    func currentMouseLocation() -> CGPoint
}
