# Insomnio

A macOS menu-bar utility that keeps your Mac awake by simulating user activity or creating a power assertion.

## Features

- **Move Cursor** -- periodically moves the mouse in a configurable pattern (nudge, circle, zigzag, random) and returns it to its original position.
- **Prevent Sleep** -- creates an IOKit power assertion to keep macOS awake without touching the cursor.
- **Only when idle** -- skips activation while you are actively using your Mac.
- **Pause on battery** -- automatically pauses when not plugged in to save battery.
- **Auto-stop timer** -- stops after a chosen duration (30 min, 1h, 2h, 4h).
- **Schedule rules** -- activate on specific days and time ranges, including overnight spans.
- **Per-app rules** -- activate when specific applications are running.
- **Global shortcut** -- toggle with `Control + Option + Command + I`.
- **Launch at login** -- start automatically via `SMAppService`.
- **Menu bar popover** -- quick access from the status bar with a live icon indicator.

## Requirements

| Requirement | Version |
|---|---|
| macOS | 26.0+ |
| Swift | 6.2 |
| Xcode | 26+ |

## Architecture

The project follows a **Clean Architecture** pattern with clear separation between domain and platform layers:

```
Insomnio/
  <Feature>/Feature/        -- Protocols and models (zero platform imports)
  <Feature>/Infrastructure/ -- Concrete implementations (CoreGraphics, IOKit, StoreKit, etc.)
  UI/                       -- SwiftUI views and view modifiers
  AppDependencies.swift     -- Composition Root
  AppCoordinator.swift      -- App startup and navigation
```

Every dependency is injected as a protocol. Infrastructure implementations are created only in the Composition Root (`AppDependencies.create()`).

### Feature modules

| Module | Purpose |
|---|---|
| **Insomniac** | Core keep-awake engine with mode, interval, and cursor pattern |
| **AutoStop** | Timer that automatically stops Insomniac after a duration |
| **Automation** | Coordinator that evaluates schedule and app rules to toggle Insomniac |
| **Schedule** | Time-based rules with weekday and hour/minute ranges |
| **AppRules** | Rules that activate based on running applications |
| **RuleStore** | Generic persistence for any `Codable` rule type |
| **CursorPattern** | Strategy pattern with four cursor movement implementations |
| **Premium** | In-app purchases via StoreKit 2 (monthly, yearly, lifetime) |
| **Shortcut** | Global keyboard shortcut registration |
| **LaunchAtLogin** | Launch-at-login via SMAppService |

## Premium

Premium features (cursor patterns, auto-stop, schedule, per-app rules) are gated behind a subscription or one-time purchase:

| Plan | Type |
|---|---|
| Monthly | Auto-renewable subscription |
| Yearly | Auto-renewable subscription |
| Lifetime | Non-consumable (one-time purchase) |

A `Products.storekit` configuration file is included for local testing with simulated purchases and a 7-day free trial on subscriptions.

## Testing

All business logic is covered by **Swift Testing** (`@Test`, `@Suite`). Tests use spy and stub doubles -- no real infrastructure is involved.

```bash
xcodebuild test -scheme Insomnio -destination 'platform=macOS'
```

Memory leak tracking is included via an `assertNoLeaks` helper that uses `autoreleasepool` and weak references.

## Building

```bash
git clone <repo-url>
open Insomnio.xcodeproj
```

Select the **Insomnio** scheme and run (Cmd+R). The StoreKit configuration is already set in the shared scheme for local purchase testing.

## License

Copyright 2026 Jesus Alfredo Hernandez Alarcon. All rights reserved.
