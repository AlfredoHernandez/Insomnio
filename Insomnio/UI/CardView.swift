//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct CardView<Content: View>: View {
	@ViewBuilder var content: Content

	var body: some View {
		content.liquidGlassCard()
	}
}

#Preview {
	CardView {
		Text("Card content")
	}
	.padding()
	.frame(width: 420)
}
