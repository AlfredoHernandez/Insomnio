//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct CardView<Content: View>: View {
	@ViewBuilder var content: Content

	var body: some View {
		content
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(14)
			.background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
	}
}

#Preview {
	CardView {
		Text("Card content")
	}
	.padding()
	.frame(width: 420)
}
