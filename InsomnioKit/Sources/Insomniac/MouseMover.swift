//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

public protocol MouseMover {
	func moveMouseTo(_ point: CGPoint) -> Bool
	func currentMouseLocation() -> CGPoint
}
