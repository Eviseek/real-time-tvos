# real-time — tvOS Clock Design

**Date:** 2026-08-24
**Status:** Approved

## Purpose

A tvOS app that displays the current time as `HH:MM:ss`, large and legible
from across a room, intended to stay on screen for hours. The user can
switch timezone, choose a visual theme, and enable a flowing gradient
animation.

## Scope

In scope:

- 24-hour `HH:MM:ss` display, updating every second
- A label naming the active timezone
- Timezone switching across all IANA zones, searchable
- Paired themes: each theme defines background *and* clock foreground
- Solid-color and `MeshGradient` backgrounds
- An animation toggle that makes mesh backgrounds flow
- A liquid-glass foreground where the background shows through the glyphs
- Preventing the tvOS screensaver while the clock is visible

Explicitly out of scope (decided during design):

- Custom color pickers. `ColorPicker`, `Slider`, and `Stepper` do not exist
  on tvOS; hand-rolled D-pad color scrubbing was judged poor UX at TV
  viewing distance. Themes are curated instead.
- Independent foreground/background selection. Rejected because it makes
  unreadable combinations reachable and doubles navigation cost.
- Date display, multiple simultaneous clocks, alarms, stopwatch.

## Platform Constraints

- Deployment target: tvOS 26.0 (`MeshGradient` needs 18+ and
  `glassEffect` needs 26+, so both are satisfied)
- Swift 6 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- SwiftUI only, no UIKit except `UIApplication.isIdleTimerDisabled`
- Project uses file-system synchronized groups: files added under
  `real-time/` join the target automatically

## Time Source

`Date()` is the source of truth. The Apple TV system clock is NTP-synced by
the OS, so no network time API is needed or wanted. `Date` is an absolute
instant with no timezone; the timezone is applied only at format time. This
is why one `Date` renders correctly in any zone with no conversion step.

Formatting uses `Date.VerbatimFormatStyle` rather than `DateFormatter`:

- It is a value type, so it is cheap to build per render — no formatter
  caching required
- It is explicitly 24-hour zero-based, so no locale can substitute 12-hour
  behaviour or non-Latin digits

## Architecture

Approach A of three considered (rejected: FuturedKit ComponentModel +
coordinator as ceremony with nothing to coordinate at three screens;
`@AppStorage` scattered through views as having no single source of truth).

One `@Observable` settings store injected through the environment, plus a
static catalog of themes as plain value types.

```
real_timeApp
  └── ClockScreen                 .environment(AppSettings)
        ├── BackgroundView        (reads theme.background)
        │     └── AnimatedMeshBackground
        ├── ClockFace             (reads theme.foreground, settings.timeZone)
        │     └── GlassClockText
        └── SettingsOverlay       (auto-hiding)
              ├── ThemeGrid → ThemeTile
              └── TimeZonePicker
```

### Data model

```swift
struct Theme: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let background: BackgroundStyle
    let foreground: ForegroundStyle
}

enum BackgroundStyle: Hashable, Sendable {
    case solid(Color)
    case mesh([Color])        // exactly 9, for a 3x3 mesh
}

enum ForegroundStyle: Hashable, Sendable {
    case solid(Color)
    case glass
}
```

`ForegroundStyle.glass` is deliberately one opaque case: how glass is
rendered is an implementation detail of `GlassClockText`, so if the
rendering strategy changes nothing else in the app is affected.

### Persistence

Three `UserDefaults` keys: `themeID`, `timeZoneID`, `isAnimated`.

Theme *IDs* are persisted, never colors. Reasons:

- `Color` is not `Codable`, and encoding components would pin saved data to
  a color space
- Themes stay code-defined, so restyling a theme in a later version
  improves it for existing users automatically

Cost: an unknown saved ID must fall back to the default theme. This
fallback is required behaviour, not an edge case to ignore.

`@AppStorage` is not usable inside an `@Observable` class, so the store
reads `UserDefaults` on init and writes in `didSet`.

## Rendering Design

### Clock tick

`TimelineView(.periodic(from: .now, by: 1))` rather than a `Timer` plus
`@State`. SwiftUI owns the schedule, so updates stop when the view is not
visible and resume automatically; there is no retain cycle or manual
invalidation. The view stays a pure function of `context.date`, so any
instant can be previewed.

`.monospacedDigit()` is required or the text jitters as digit widths change.

### Mesh animation

`MeshGradient(width: 3, height: 3, points:, colors:)` — 9 control points.

**The four corner points stay pinned** at (0,0) (1,0) (0,1) (1,1). Only the
four edge midpoints and the centre move. Animating corners shrinks the
mesh's domain below the screen bounds and produces undefined color at the
edges.

Motion is `sin`/`cos` of elapsed time with a **different frequency and
phase per point**. Shared frequencies drift in lockstep and read as
mechanical; detuned frequencies never visibly repeat, which is what makes
the motion read as liquid.

Driven by `TimelineView(.animation(minimumInterval: 1.0/30.0, paused:))`:

- 30fps, not 60: the motion is slow enough that 30 is visually identical,
  while halving GPU work on a display intended to stay on for hours
- The `paused:` parameter rather than swapping views: the mesh still
  renders at `t = 0` when paused, so animation-off shows the same colors
  as the animated theme rather than a different-looking view

### View hierarchy constraint

The background and the clock are **ZStack siblings, never nested**. The
background re-renders at 30fps; the clock at 1Hz. Nested, the background
would force 30 clock re-renders per second for no reason.

### Animation toggle applies only to mesh themes

A solid color has nothing to flow. The toggle is shown *disabled with an
explanatory caption* for solid themes rather than hidden, so the control
does not appear and vanish as the user browses.

### Glass glyphs — unresolved, requires a spike

`Text` is not a `Shape`, so `glassEffect(_:in:)` cannot take glyph
geometry. Strategies to try in order on the Apple TV 4K simulator:

1. `GlassEffectContainer` + filled rect `.mask { Text(...) }` — the real
   thing if glass composites through a mask
2. `.foregroundStyle(.ultraThinMaterial)` on the `Text` — materials are
   valid `ShapeStyle`s so this compiles for certain; frosted rather than
   liquid, but honest glass
3. `.blendMode(.overlay)` vibrancy over the mesh

Pass criteria: the mesh must be visibly moving through the digits, and the
time must remain readable at distance. The chosen strategy is reported with
a screenshot, not asserted.

## Interaction Design

### Settings entry

The clock is fully immersive. Any remote press reveals an overlay bar
(Theme / Timezone / Animation) which fades out after 5 seconds of no input.
This is the standard tvOS player pattern and keeps the clock clean.

### Focus

Focus appearance is not optional on tvOS. Every tile uses
`.buttonStyle(.card)` for Apple's standard focused treatment. `Menu`
dismisses via `onExitCommand`.

### Timezone list

A flat searchable `LazyVGrid` over all ~600 `TimeZone.knownTimeZoneIdentifiers`.
Chosen over region grouping by explicit user decision. Mitigations:

- `LazyVGrid` so only visible cells are built
- `.searchable` filtering over prettified names ("Europe/Prague" →
  "Prague · Europe") so a few keystrokes narrow the list
- Identifiers sorted by city name, not raw identifier

### Screensaver

`UIApplication.shared.isIdleTimerDisabled = true` while the clock is
visible, restored on disappear. A clock with no remote input is idle by
definition, so without this the screensaver covers it. Set on
appear/disappear rather than once at launch, so the flag is not held
forever.

## Accessibility

- `accessibilityReduceMotion` freezes the mesh. Continuous background
  motion is precisely what this setting exists for.
- `accessibilityReduceTransparency` falls back from glass to a solid
  foreground.
- The clock exposes an accessibility label with the spoken time.

## Testing

No automated tests, per the user's standing preference. Three seams are
genuinely unit-testable if that changes later:

1. Timezone formatting across a DST boundary
2. Theme-ID fallback when a persisted ID no longer exists
3. Mesh point generation staying within 0...1

Verification is per-task: build for the Apple TV 4K simulator and confirm a
stated visual expectation.

## Risks

| Risk | Mitigation |
|---|---|
| Glass glyphs may not composite through a mask | Spike first; two fallbacks defined; isolated behind one enum case |
| 600-cell grid focus performance | `LazyVGrid`, measured on simulator |
| Mesh at 30fps on older hardware | Pinned corners, small offsets, `paused:` when off |
