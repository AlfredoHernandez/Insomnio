//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import Insomnio
import AppKit
import Shortcut

final nonisolated class KeyEventMonitorSpy: KeyEventMonitor, @unchecked Sendable {
	final class Token {}

	enum ReceivedMessage: Equatable {
		case addGlobal
		case addLocal
		case remove(ObjectIdentifier)
	}

	private let lock = NSLock()
	private var _receivedMessages = [ReceivedMessage]()
	private var _globalHandler: ((NSEvent) -> Void)?
	private var _localHandler: ((NSEvent) -> NSEvent?)?
	private var _globalToken: Token?
	private var _localToken: Token?
	private var _stubbedGlobalReturnsNil = false
	private var _stubbedLocalReturnsNil = false

	var receivedMessages: [ReceivedMessage] {
		lock.withLock { _receivedMessages }
	}

	var globalHandler: ((NSEvent) -> Void)? {
		lock.withLock { _globalHandler }
	}

	var localHandler: ((NSEvent) -> NSEvent?)? {
		lock.withLock { _localHandler }
	}

	var globalToken: Token? {
		lock.withLock { _globalToken }
	}

	var localToken: Token? {
		lock.withLock { _localToken }
	}

	var stubbedGlobalReturnsNil: Bool {
		get { lock.withLock { _stubbedGlobalReturnsNil } }
		set { lock.withLock { _stubbedGlobalReturnsNil = newValue } }
	}

	var stubbedLocalReturnsNil: Bool {
		get { lock.withLock { _stubbedLocalReturnsNil } }
		set { lock.withLock { _stubbedLocalReturnsNil = newValue } }
	}

	func addGlobal(handler: @escaping (NSEvent) -> Void) -> Any? {
		lock.withLock {
			_receivedMessages.append(.addGlobal)
			_globalHandler = handler
			if _stubbedGlobalReturnsNil { return nil }
			let token = Token()
			_globalToken = token
			return token
		}
	}

	func addLocal(handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
		lock.withLock {
			_receivedMessages.append(.addLocal)
			_localHandler = handler
			if _stubbedLocalReturnsNil { return nil }
			let token = Token()
			_localToken = token
			return token
		}
	}

	func remove(_ token: Any) {
		guard let token = token as? Token else { return }
		lock.withLock {
			_receivedMessages.append(.remove(ObjectIdentifier(token)))
		}
	}
}
