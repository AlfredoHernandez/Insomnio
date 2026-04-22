//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit

struct AppInfo: Identifiable {
	let bundleID: String
	let name: String
	let icon: NSImage
	var id: String {
		bundleID
	}
}
