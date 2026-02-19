//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreGraphics

class MouseMoverStub: MouseMover {
	func moveMouseTo(_: CGPoint) -> Bool {
		true
	}

	func currentMouseLocation() -> CGPoint {
		.zero
	}
}
