//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import AppKit
import Shortcut

/// @unchecked Sendable: every mutable field (`_receivedMessages`, `_globalHandler`,
/// `_localHandler`, `_globalToken`, `_localToken`, `_stubbedGlobalReturnsNil`,
/// `_stubbedLocalReturnsNil`) is only accessed behind `lock.withLock { ... }`.
public final nonisolated class KeyEventMonitorSpy: KeyEventMonitor, @unchecked Sendable {
	public final class Token {}

	public enum ReceivedMessage: Equatable {
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

	public init() {}

	public var receivedMessages: [ReceivedMessage] {
		lock.withLock { _receivedMessages }
	}

	public var globalHandler: ((NSEvent) -> Void)? {
		lock.withLock { _globalHandler }
	}

	public var localHandler: ((NSEvent) -> NSEvent?)? {
		lock.withLock { _localHandler }
	}

	public var globalToken: Token? {
		lock.withLock { _globalToken }
	}

	public var localToken: Token? {
		lock.withLock { _localToken }
	}

	public var stubbedGlobalReturnsNil: Bool {
		get { lock.withLock { _stubbedGlobalReturnsNil } }
		set { lock.withLock { _stubbedGlobalReturnsNil = newValue } }
	}

	public var stubbedLocalReturnsNil: Bool {
		get { lock.withLock { _stubbedLocalReturnsNil } }
		set { lock.withLock { _stubbedLocalReturnsNil = newValue } }
	}

	public func addGlobal(handler: @escaping (NSEvent) -> Void) -> Any? {
		lock.withLock {
			_receivedMessages.append(.addGlobal)
			_globalHandler = handler
			if _stubbedGlobalReturnsNil { return nil }
			let token = Token()
			_globalToken = token
			return token
		}
	}

	public func addLocal(handler: @escaping (NSEvent) -> NSEvent?) -> Any? {
		lock.withLock {
			_receivedMessages.append(.addLocal)
			_localHandler = handler
			if _stubbedLocalReturnsNil { return nil }
			let token = Token()
			_localToken = token
			return token
		}
	}

	public func remove(_ token: Any) {
		guard let token = token as? Token else { return }
		lock.withLock {
			_receivedMessages.append(.remove(ObjectIdentifier(token)))
		}
	}
}
