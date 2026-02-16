//
// Copyright © 2026 Jesus Alfredo Hernandez Alarcon. All rights reserved.
//

import CoreGraphics
import Testing
@testable import Insomnio

@MainActor
@Suite("MouseJiggler")
struct MouseJigglerTests {
    @Test("Init does not message mouse mover upon creation")
    func init_doesNotMessageMouseMoverUponCreation() {
        let (_, mover) = makeSUT()

        #expect(mover.receivedMessages == [])
    }

    @Test("Init is not active")
    func init_isNotActive() {
        let (sut, _) = makeSUT()

        #expect(sut.isActive == false)
    }

    @Test("Init default interval is 30 seconds")
    func init_defaultIntervalIs30Seconds() {
        let (sut, _) = makeSUT()

        #expect(sut.interval == 30.0)
    }

    @Test("Start sets isActive to true")
    func start_setsIsActiveToTrue() {
        let (sut, _) = makeSUT()

        sut.start()

        #expect(sut.isActive == true)
    }

    @Test("Stop sets isActive to false")
    func stop_setsIsActiveToFalse() {
        let (sut, _) = makeSUT()

        sut.start()
        sut.stop()

        #expect(sut.isActive == false)
    }

    @Test("Toggle starts when inactive")
    func toggle_startsWhenInactive() {
        let (sut, _) = makeSUT()

        sut.toggle()

        #expect(sut.isActive == true)
    }

    @Test("Toggle stops when active")
    func toggle_stopsWhenActive() {
        let (sut, _) = makeSUT()

        sut.start()
        sut.toggle()

        #expect(sut.isActive == false)
    }

    @Test("Jiggle moves cursor right then back to original")
    func jiggle_movesCursorRightThenBackToOriginal() {
        let (sut, mover) = makeSUT()
        mover.stubbedLocation = CGPoint(x: 50, y: 75)

        sut.jiggle()

        #expect(mover.receivedMessages == [
            .currentLocation,
            .moveTo(CGPoint(x: 51, y: 75)),
            .moveTo(CGPoint(x: 50, y: 75)),
        ])
    }

    @Test("Start does not start twice")
    func start_doesNotStartTwice() {
        let (sut, _) = makeSUT()

        sut.start()
        sut.start()

        #expect(sut.isActive == true)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: MouseJiggler, mover: MouseMoverSpy) {
        let mover = MouseMoverSpy()
        let sut = MouseJiggler(mouseMover: mover)
        return (sut, mover)
    }
}
