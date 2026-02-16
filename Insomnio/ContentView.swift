//
// Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var jiggler: MouseJiggler

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: jiggler.isActive ? "cursorarrow.motionlines" : "cursorarrow")
                .imageScale(.large)
                .foregroundStyle(jiggler.isActive ? .green : .secondary)
                .font(.system(size: 48))

            Text(jiggler.isActive ? "Jiggling..." : "Inactive")
                .font(.title2)

            Toggle("Enable Jiggler", isOn: Binding(
                get: { jiggler.isActive },
                set: { newValue in
                    if newValue { jiggler.start() } else { jiggler.stop() }
                }
            ))
            .toggleStyle(.switch)

            HStack {
                Text("Interval:")
                TextField("Seconds", value: $jiggler.interval, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text("seconds")
            }
            .disabled(jiggler.isActive)
        }
        .padding(40)
        .frame(minWidth: 300, minHeight: 250)
    }
}

#Preview {
    ContentView(jiggler: MouseJiggler(mouseMover: CGMouseMover()))
}
