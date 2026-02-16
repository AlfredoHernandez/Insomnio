//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

protocol IdleTimeProvider {
	func secondsSinceLastUserInput() -> TimeInterval
}
