//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppKit
import Shortcut
import Testing

@MainActor
struct NSEventGlobalShortcutManagerTests {
	@Test
	func `Unregister is idempotent when nothing was registered`() {
		let (sut, monitor) = makeSUT()

		sut.unregisterShortcut()

		#expect(monitor.receivedMessages.isEmpty)
	}

	@Test
	func `Register installs one global and one local monitor`() {
		let (sut, monitor) = makeSUT()

		sut.registerShortcut {}

		#expect(monitor.receivedMessages == [.addGlobal, .addLocal])
	}

	@Test
	func `Register unregisters previous monitors before installing new ones`() throws {
		let (sut, monitor) = makeSUT()
		sut.registerShortcut {}
		let firstGlobal = try #require(monitor.globalToken)
		let firstLocal = try #require(monitor.localToken)

		sut.registerShortcut {}

		#expect(monitor.receivedMessages.contains(.remove(ObjectIdentifier(firstGlobal))))
		#expect(monitor.receivedMessages.contains(.remove(ObjectIdentifier(firstLocal))))
	}

	@Test
	func `Unregister removes both installed monitors`() throws {
		let (sut, monitor) = makeSUT()
		sut.registerShortcut {}
		let globalToken = try #require(monitor.globalToken)
		let localToken = try #require(monitor.localToken)

		sut.unregisterShortcut()

		#expect(monitor.receivedMessages.contains(.remove(ObjectIdentifier(globalToken))))
		#expect(monitor.receivedMessages.contains(.remove(ObjectIdentifier(localToken))))
	}

	@Test
	func `Double unregister after register only removes once`() {
		let (sut, monitor) = makeSUT()
		sut.registerShortcut {}
		sut.unregisterShortcut()
		let removeCountAfterFirst = monitor.receivedMessages.count(where: { if case .remove = $0 { true } else { false } })

		sut.unregisterShortcut()

		let removeCountAfterSecond = monitor.receivedMessages.count(where: { if case .remove = $0 { true } else { false } })
		#expect(removeCountAfterFirst == removeCountAfterSecond)
	}

	// MARK: - Memory Leak Tracking

	@Test
	func `makeSUT does not leak sut after unregister`() {
		// The spy is intentionally not leak-tracked: `deinit` hops through
		// `DispatchQueue.main.async` which strongly captures the injected
		// `KeyEventMonitor` until the block fires on the next runloop tick,
		// producing a false-positive leak if we assert synchronously.
		assertNoLeaks {
			let sut = NSEventGlobalShortcutManager(monitor: KeyEventMonitorSpy())
			sut.registerShortcut {}
			sut.unregisterShortcut()
			return [sut]
		}
	}

	// MARK: - Helpers

	private func makeSUT() -> (NSEventGlobalShortcutManager, KeyEventMonitorSpy) {
		let monitor = KeyEventMonitorSpy()
		let sut = NSEventGlobalShortcutManager(monitor: monitor)
		return (sut, monitor)
	}
}
