//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import IOKit.ps

struct IOKitPowerSourceProvider: PowerSourceProvider {
	func isOnBatteryPower() -> Bool {
		guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
		      let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
		      let first = sources.first,
		      let description = IOPSGetPowerSourceDescription(snapshot, first)?.takeUnretainedValue() as? [String: Any],
		      let powerSource = description[kIOPSPowerSourceStateKey] as? String
		else {
			return false
		}
		return powerSource == kIOPSBatteryPowerValue
	}
}
