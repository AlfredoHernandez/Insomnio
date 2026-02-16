//
// Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

@Observable
final class Insomniac {
    private let mouseMover: MouseMover
    private var timer: Timer?

    var isActive: Bool = false
    var interval: TimeInterval = 30.0

    init(mouseMover: MouseMover) {
        self.mouseMover = mouseMover
    }

    func toggle() {
        isActive ? stop() : start()
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        scheduleTimer()
    }

    func stop() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }

    func keepAwake() {
        let currentPosition = mouseMover.currentMouseLocation()
        let nudged = CGPoint(x: currentPosition.x + 1, y: currentPosition.y)
        _ = mouseMover.moveMouseTo(nudged)
        _ = mouseMover.moveMouseTo(currentPosition)
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.keepAwake()
        }
    }
}
