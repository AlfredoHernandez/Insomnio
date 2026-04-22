//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import CoreGraphics

final class MouseMoverPreviewStub: MouseMover {
	func moveMouseTo(_: CGPoint) -> Bool {
		true
	}

	func currentMouseLocation() -> CGPoint {
		.zero
	}
}
#endif
