//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import Testing

@MainActor
func assertNoLeaks(
	sourceLocation: SourceLocation = #_sourceLocation,
	_ body: @MainActor () -> [AnyObject],
) {
	var weakRefs: [() -> AnyObject?] = []
	autoreleasepool {
		let instances = body()
		weakRefs = instances.map { instance in
			{ [weak instance] in instance }
		}
	}
	for ref in weakRefs {
		#expect(ref() == nil, "Instance should have been deallocated. Potential memory leak!", sourceLocation: sourceLocation)
	}
}
