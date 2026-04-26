//
//  Copyright © 2026 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

/// Represents a single "keep awake" session on the timeline.
///
/// Produced each time ``Insomniac/start()`` succeeds and closed with
/// ``Insomniac/stop()``. Open events have a `nil` ``endDate``.
public struct ActivationEvent: Sendable, Equatable, Identifiable {
	public let id: UUID
	public let startDate: Date
	public let endDate: Date?
	public let source: Insomniac.ActivationSource

	public init(
		id: UUID = UUID(),
		startDate: Date,
		endDate: Date? = nil,
		source: Insomniac.ActivationSource,
	) {
		self.id = id
		self.startDate = startDate
		self.endDate = endDate
		self.source = source
	}

	/// Duration of the session. `nil` while the event is still open.
	public var duration: TimeInterval? {
		endDate.map { $0.timeIntervalSince(startDate) }
	}
}
