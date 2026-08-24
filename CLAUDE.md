# real-time — Project Rules

tvOS 26 SwiftUI clock. Swift 6 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
no third-party dependencies.

## Architecture

Four top-level folders under `real-time/`. Nothing lives outside them except
`real_timeApp.swift`.

| Folder | Holds |
|---|---|
| `Library/` | Pure logic and reusable plumbing with no domain meaning: geometry, constants, view modifiers |
| `Models/` | Domain types, the theme catalog, the settings store, and their protocols |
| `Views/` | SwiftUI views only, grouped in subfolders by screen area (`Clock/`, `Background/`, `Foreground/`, `Settings/`) |
| `Resources/` | Asset catalogs, Info.plist entries, localization |

The project uses a file-system synchronized group: any `.swift` file created
under `real-time/` joins the target automatically. **Never hand-edit
`project.pbxproj`.**

## One type per file

Exactly one top-level `struct`, `class`, or `enum` per file, and the filename
matches it. A nested type used only by its parent (a private `Keys` enum, for
example) may stay inside the parent — a nested type is not a top-level type.

## No magic numbers

No numeric literal appears inline in a view or model. Every one is a named
constant with a documentation comment explaining what it is and why it has that
value.

- **`Library/Metrics.swift`** — all spacing, padding, corner radii, font sizes,
  and frame dimensions. One file, one `Metrics` namespace, nested types per area.
- **Behavioural constants** (frame rates, animation amplitudes, timer durations)
  belong beside the code that uses them, not in `Metrics` — `Metrics` is layout.

`0`, `1`, and `-1` used as identity or index values are not magic numbers.

## Views are at most 30 lines

A view file's `struct` declaration is at most 30 lines, braces included. Past
that, extract a subview into its own file rather than adding a computed
property. This is a hard limit, not a guideline: it is what keeps `body`
readable at a glance.

## Access dependencies through protocols

Any injected or behavioural type is consumed through a protocol, never its
concrete type, so it can be substituted:

- `AppSettings` is consumed as `any AppSettingsProviding`
- `ThemeCatalog` is consumed as `any ThemeProviding`

Injected via a custom `EnvironmentKey`, because SwiftUI's
`.environment(SomeType.self)` requires a concrete `@Observable` class and
cannot carry an existential.

Pure value models (`Theme`, `BackgroundStyle`, `ForegroundStyle`) are used
directly. A protocol over a field-only value type adds indirection without
creating a seam.

## SwiftUI

- SwiftUI only. The single permitted UIKit use is
  `UIApplication.shared.isIdleTimerDisabled`.
- Background and clock stay `ZStack` **siblings**, never nested, so each ticks
  at its own rate (30fps vs 1Hz).
- `.monospacedDigit()` on every view rendering time digits.
- Mesh backgrounds use exactly 9 colors (3×3). The four corner control points
  are never animated.

## Tests

No automated tests unless explicitly requested. Every change ends with a
simulator build and a stated visual expectation.

```bash
xcodebuild -project real-time.xcodeproj -scheme real-time \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  build 2>&1 | tail -5
```
