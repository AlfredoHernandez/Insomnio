//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

public protocol RunningAppProvider {
	func runningAppBundleIdentifiers() -> Set<String>
}
