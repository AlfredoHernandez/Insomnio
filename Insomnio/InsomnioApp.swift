//
// Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

@main
struct InsomnioApp: App {
    @State private var jiggler = MouseJiggler(mouseMover: CGMouseMover())

    var body: some Scene {
        WindowGroup {
            ContentView(jiggler: jiggler)
        }
    }
}
