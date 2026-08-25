# real-time — Project Rules

tvOS 26 SwiftUI clock. Swift 6 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
no third-party dependencies.

## Architecture

Four top-level folders under `real-time/`. Nothing lives outside them except
`real_timeApp.swift`.

| Folder | Holds |
|---|---|
| `Library/` | Reusable plumbing with no screen of its own: geometry, constants, extensions, view modifiers, and in `Library/Views/` any view used by more than one screen |
| `Models/` | Domain types and their protocols, grouped in subfolders by domain (`Theme/`, `TimeZone/`, `Settings/`) |
| `Views/` | One subfolder per screen and nothing else (`Clock/`, `ThemePicker/`, `TimeZonePicker/`) |
| `Resources/` | Asset catalogs, Info.plist entries, localization |

Every folder under `Views/` is a **screen**, not a kind of widget: everything
the clock screen draws — including the settings bar that sits on top of it —
lives in `Clock/`.

A view used by more than one screen is reusable plumbing, so it belongs to
`Library/Views/` rather than to whichever screen happened to need it first.
`BackgroundView` and `GlassClockText` are both drawn by the clock and by the
theme tiles. The test is the caller count, and it runs both ways: promote a view
to `Library/Views/` when a second screen starts using it, and move it back down
into a screen's folder when it drops to one caller.

A model subfolder holds one domain: its types, its catalog, and the protocol
those are consumed through. A type that only exists as part of another —
`BackgroundStyle` and `ForegroundStyle` are two halves of a `Theme` — belongs
in that domain's folder, not in one of its own.

The project uses a file-system synchronized group: any `.swift` file created
under `real-time/` joins the target automatically. **Never hand-edit
`project.pbxproj`.**

## One type per file

Exactly one top-level `struct`, `class`, or `enum` per file, and the filename
matches it. A nested type used only by its parent (a private `Keys` enum, for
example) may stay inside the parent — a nested type is not a top-level type.

## Extensions

An extension of an existing type lives in `Library/Extensions/`, in a file
named `[Type]+Extensions.swift` — `Color+Extensions.swift`,
`View+Extensions.swift`, `Comparable+Extensions.swift`. One file per extended
type, however many members it holds: the folder is browsable by the type being
extended, not by whichever feature happened to need it.

Two cases deliberately stay put:

- Members of a type belong **in** that type, not in a same-file extension
  after it. If you are reaching for `extension Foo` inside `Foo.swift`, put the
  member in `Foo` instead.
- A `ViewModifier` and the `extension View` that exposes it stay together in
  the modifier's own file, so the modifier can remain `private`. Splitting them
  would force it to internal for no gain.

## No magic numbers

No numeric literal appears inline in a view or model. Every one is a named
constant with a documentation comment explaining what it is and why it has that
value.

- **`Library/Metrics.swift`** — all spacing, padding, corner radii, font sizes,
  and frame dimensions. One file, one `Metrics` namespace, nested types per area.
- **Behavioural constants** (frame rates, animation amplitudes, timer durations)
  belong beside the code that uses them, not in `Metrics` — `Metrics` is layout.

`0`, `1`, and `-1` used as identity or index values are not magic numbers.

Palette hex literals in `ThemeCatalog` are also exempt: each one sits on the
line that names the theme it belongs to, so `mesh("forest", "Forest",
0x0E1512, ...)` already documents itself. Lifting seventy colors into
separately named constants would add a layer of indirection without adding
information.

## Switch statements

Every `case`'s implementation goes on its own new line, never after the colon
on the `case` line — including single-expression bodies used as an implicit
return.

```swift
// Not this:
case .white: "White"

// This:
case .white:
    "White"
```

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
- **No `Spacer()`.** To push a view to an edge or fill an axis, use
  `.frame(maxWidth:)` / `.frame(maxHeight:)` with an `alignment:`. A `Spacer`
  is an invisible sibling that only works inside a stack, so reaching for one
  usually means adding a stack whose only job is to hold it — a frame states
  the same intent on the view itself and needs no wrapper. Put the frame
  **after** any padding, or the padding is added outside the filled area
  instead of inside it.
- Mesh backgrounds are a 5×5 `MeshGradient`, so `MeshColors` must return
  exactly 25 colors. Control points on the mesh boundary may slide **along**
  their edge but never off it, and the four corners never move: the boundary is
  the drawn region, so a point leaving it exposes undefined color.
- The mesh is drawn larger than the view and swept beneath it (`MeshDrift`),
  which is what lets a colour cross the whole screen. Any change to `overscan`
  or `travel` must keep `travel < (overscan - 1) / 2`.

## Tests

No automated tests unless explicitly requested. Every change ends with a
simulator build and a stated visual expectation.

```bash
xcodebuild -project real-time.xcodeproj -scheme real-time \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  build 2>&1 | tail -5
```
