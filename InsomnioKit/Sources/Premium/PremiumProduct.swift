//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

public enum PremiumProduct: String, CaseIterable {
	case monthly = "io.alfredohdz.Insomnio.premium.monthly"
	case yearly = "io.alfredohdz.Insomnio.premium.yearly"
	case lifetime = "io.alfredohdz.Insomnio.premium.lifetime"

	public static let subscriptionGroupID = "21940076"
}
