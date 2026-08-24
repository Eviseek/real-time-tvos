# real-time tvOS Clock — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A tvOS clock showing `HH:MM:ss` with timezone switching, curated paired themes, an animated `MeshGradient` background, and a liquid-glass glyph foreground.

**Architecture:** One `@Observable AppSettings` store injected via `.environment()`, plus a static catalog of `Theme` value types. Background and clock are `ZStack` siblings so each ticks at its own rate (30fps vs 1Hz). Theme IDs are persisted, never colors.

**Tech Stack:** SwiftUI, tvOS 26, Swift 6 language mode with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. No third-party dependencies.

**Spec:** `docs/superpowers/specs/2026-08-24-tvos-clock-design.md`

## Global Constraints

- Deployment target tvOS 26.0; Swift version 6.0; default actor isolation `MainActor`
- SwiftUI only. The single permitted UIKit use is `UIApplication.shared.isIdleTimerDisabled`
- No third-party packages
- **No automated tests** (standing user preference). Every task instead ends with a simulator build and a stated visual expectation
- Project uses file-system synchronized groups: any `.swift` file created under `real-time/` joins the target automatically. Never hand-edit `project.pbxproj`
- Mesh backgrounds use exactly 9 colors (3×3). The four corner control points at (0,0) (1,0) (0,1) (1,1) are **never** animated
- Background and clock must remain `ZStack` siblings, never nested
- `.monospacedDigit()` on every view rendering time digits
- Standard build/verify command, used verbatim in every task:

```bash
cd "/Users/evachlpikova/Documents/Moje projekty/real-time"
xcodebuild -project real-time.xcodeproj -scheme real-time \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  build 2>&1 | tail -5
```

## File Structure

| File | Responsibility |
|---|---|
| `real-time/Models/Theme.swift` | `Theme`, `BackgroundStyle`, `ForegroundStyle` value types |
| `real-time/Models/ThemeCatalog.swift` | The static list of themes and ID lookup with fallback |
| `real-time/Models/AppSettings.swift` | `@Observable` store; persists three `UserDefaults` keys |
| `real-time/Models/MeshPoints.swift` | Control-point geometry and the animation function |
| `real-time/Clock/ClockScreen.swift` | Top-level `ZStack` composition |
| `real-time/Clock/ClockFace.swift` | 1Hz `TimelineView`, `HH:MM:ss` + timezone label |
| `real-time/Background/BackgroundView.swift` | Switches on `BackgroundStyle` |
| `real-time/Background/AnimatedMeshBackground.swift` | 30fps mesh with pause + reduce-motion |
| `real-time/Foreground/GlassClockText.swift` | The glass-glyph rendering, isolated |
| `real-time/Settings/SettingsOverlay.swift` | Auto-hiding bar and its visibility timer |
| `real-time/Settings/ThemeGrid.swift` | Theme selection grid |
| `real-time/Settings/ThemeTile.swift` | One tile, rendering a live miniature |
| `real-time/Settings/TimeZonePicker.swift` | Searchable `LazyVGrid` of all zones |
| `real-time/Support/IdleTimerModifier.swift` | Screensaver suppression |
| `real-time/ContentView.swift` | **Deleted** in Task 2 |

---

### Task 1: Theme model and catalog

**Files:**
- Create: `real-time/Models/Theme.swift`
- Create: `real-time/Models/ThemeCatalog.swift`

**Interfaces:**
- Consumes: nothing
- Produces: `Theme` (`id: String`, `name: String`, `background: BackgroundStyle`, `foreground: ForegroundStyle`); `BackgroundStyle.solid(Color)` / `.mesh([Color])`; `ForegroundStyle.solid(Color)` / `.glass`; `ThemeCatalog.all: [Theme]`, `ThemeCatalog.default: Theme`, `ThemeCatalog.theme(id: String) -> Theme`

- [ ] **Step 1: Create the model types**

```swift
// real-time/Models/Theme.swift
import SwiftUI

struct Theme: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let background: BackgroundStyle
    let foreground: ForegroundStyle
}

enum BackgroundStyle: Hashable, Sendable {
    case solid(Color)
    /// Exactly 9 colors, for a 3x3 MeshGradient.
    case mesh([Color])

    var isMesh: Bool {
        if case .mesh = self { return true }
        return false
    }
}

enum ForegroundStyle: Hashable, Sendable {
    case solid(Color)
    /// Liquid glass: the background shows through the glyphs.
    /// How that is achieved is private to GlassClockText.
    case glass
}
```

- [ ] **Step 2: Create the catalog**

```swift
// real-time/Models/ThemeCatalog.swift
import SwiftUI

enum ThemeCatalog {
    /// Expands three colors into the 9 a 3x3 mesh needs.
    private static func mesh(_ a: Color, _ b: Color, _ c: Color) -> BackgroundStyle {
        .mesh([a, b, c,
               b, c, a,
               c, a, b])
    }

    static let all: [Theme] = [
        Theme(id: "midnight",
              name: "Midnight",
              background: .solid(.black),
              foreground: .solid(.white)),

        Theme(id: "paper",
              name: "Paper",
              background: .solid(Color(white: 0.94)),
              foreground: .solid(Color(white: 0.08))),

        Theme(id: "ember",
              name: "Ember",
              background: mesh(Color(red: 0.35, green: 0.05, blue: 0.02),
                               Color(red: 0.85, green: 0.28, blue: 0.05),
                               Color(red: 0.98, green: 0.62, blue: 0.15)),
              foreground: .solid(.white)),

        Theme(id: "ocean",
              name: "Ocean",
              background: mesh(Color(red: 0.02, green: 0.09, blue: 0.28),
                               Color(red: 0.05, green: 0.35, blue: 0.62),
                               Color(red: 0.20, green: 0.72, blue: 0.80)),
              foreground: .solid(.white)),

        Theme(id: "aurora",
              name: "Aurora",
              background: mesh(Color(red: 0.04, green: 0.16, blue: 0.20),
                               Color(red: 0.10, green: 0.62, blue: 0.45),
                               Color(red: 0.45, green: 0.25, blue: 0.72)),
              foreground: .glass),

        Theme(id: "dusk",
              name: "Dusk",
              background: mesh(Color(red: 0.14, green: 0.05, blue: 0.28),
                               Color(red: 0.55, green: 0.15, blue: 0.45),
                               Color(red: 0.95, green: 0.45, blue: 0.35)),
              foreground: .glass),
    ]

    static let `default`: Theme = all[0]

    /// Falls back to the default when a persisted ID no longer exists —
    /// required behaviour, since themes are code-defined and may be removed.
    static func theme(id: String) -> Theme {
        all.first { $0.id == id } ?? `default`
    }
}
```

- [ ] **Step 3: Build to verify it compiles**

Run the standard build command.
Expected: `** BUILD SUCCEEDED **`. Nothing visual changes yet — `ContentView` still renders.

- [ ] **Step 4: Commit**

```bash
git add real-time/Models/Theme.swift real-time/Models/ThemeCatalog.swift
git commit -m "feat: add Theme model and theme catalog"
```

---

### Task 2: Settings store, app wiring, remove template view

**Files:**
- Create: `real-time/Models/AppSettings.swift`
- Create: `real-time/Clock/ClockScreen.swift`
- Modify: `real-time/real_timeApp.swift`
- Delete: `real-time/ContentView.swift`

**Interfaces:**
- Consumes: `ThemeCatalog.default`, `ThemeCatalog.theme(id:)`
- Produces: `AppSettings` with `themeID: String`, `timeZoneID: String`, `isAnimated: Bool`, and computed `theme: Theme`, `timeZone: TimeZone`; `ClockScreen()`

- [ ] **Step 1: Create the store**

```swift
// real-time/Models/AppSettings.swift
import SwiftUI

@Observable
final class AppSettings {
    private enum Keys {
        static let themeID = "themeID"
        static let timeZoneID = "timeZoneID"
        static let isAnimated = "isAnimated"
    }

    private let defaults: UserDefaults

    // @AppStorage cannot be used inside a class, so persistence is
    // explicit: read once in init, write on every mutation.
    // didSet does not fire during init, so init performs no redundant writes.
    var themeID: String { didSet { defaults.set(themeID, forKey: Keys.themeID) } }
    var timeZoneID: String { didSet { defaults.set(timeZoneID, forKey: Keys.timeZoneID) } }
    var isAnimated: Bool { didSet { defaults.set(isAnimated, forKey: Keys.isAnimated) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.themeID = defaults.string(forKey: Keys.themeID) ?? ThemeCatalog.default.id
        self.timeZoneID = defaults.string(forKey: Keys.timeZoneID) ?? TimeZone.current.identifier
        self.isAnimated = defaults.object(forKey: Keys.isAnimated) as? Bool ?? true
    }

    var theme: Theme { ThemeCatalog.theme(id: themeID) }
    var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }
}
```

- [ ] **Step 2: Create a placeholder ClockScreen**

Real composition arrives in Task 4. This exists so the app has a root.

```swift
// real-time/Clock/ClockScreen.swift
import SwiftUI

struct ClockScreen: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(settings.theme.name)
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
    }
}
```

- [ ] **Step 3: Wire the store into the app and drop the template view**

```swift
// real-time/real_timeApp.swift
import SwiftUI

@main
struct real_timeApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ClockScreen()
                .environment(settings)
        }
    }
}
```

```bash
rm real-time/ContentView.swift
```

- [ ] **Step 4: Build and run**

Run the standard build command, then launch in the simulator.
Expected: `** BUILD SUCCEEDED **`, and a black screen reading "Midnight". Confirms the store is injected and resolves a theme.

- [ ] **Step 5: Commit**

```bash
git add -A real-time/
git commit -m "feat: add AppSettings store, wire ClockScreen, remove template view"
```

---

### Task 3: Mesh geometry and static background

**Files:**
- Create: `real-time/Models/MeshPoints.swift`
- Create: `real-time/Background/BackgroundView.swift`
- Modify: `real-time/Clock/ClockScreen.swift`

**Interfaces:**
- Consumes: `BackgroundStyle`, `AppSettings.theme`
- Produces: `MeshPoints.points(at: Double, amplitude: Float) -> [SIMD2<Float>]`; `BackgroundView(style: BackgroundStyle, isAnimating: Bool)`

- [ ] **Step 1: Create the control-point geometry**

```swift
// real-time/Models/MeshPoints.swift
import Foundation

enum MeshPoints {
    /// Row-major 3x3 grid. Indices 0, 2, 6, 8 are the corners.
    static let base: [SIMD2<Float>] = [
        SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
        SIMD2(0.0, 0.5), SIMD2(0.5, 0.5), SIMD2(1.0, 0.5),
        SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0),
    ]

    /// Corners are pinned. Moving them shrinks the mesh domain below the
    /// screen bounds, which renders undefined color at the edges.
    private static let cornerIndices: Set<Int> = [0, 2, 6, 8]

    /// Detuned per point: shared frequencies drift in lockstep and read as
    /// mechanical, while these never visibly repeat.
    private static let frequencyX: [Float] = [0, 0.31, 0, 0.23, 0.17, 0.29, 0, 0.19, 0]
    private static let frequencyY: [Float] = [0, 0.24, 0, 0.33, 0.21, 0.27, 0, 0.35, 0]
    private static let phase: [Float]      = [0, 0.00, 0, 1.70, 3.10, 4.60, 0, 2.40, 0]

    static func points(at time: Double, amplitude: Float = 0.08) -> [SIMD2<Float>] {
        let t = Float(time)
        return base.enumerated().map { index, point in
            guard !cornerIndices.contains(index) else { return point }
            let dx = sin(t * frequencyX[index] + phase[index]) * amplitude
            let dy = cos(t * frequencyY[index] + phase[index]) * amplitude
            return SIMD2(
                min(max(point.x + dx, 0), 1),
                min(max(point.y + dy, 0), 1)
            )
        }
    }
}
```

- [ ] **Step 2: Create the background switch**

`isAnimating` is accepted now but only honoured in Task 5, so the call site does not change later.

```swift
// real-time/Background/BackgroundView.swift
import SwiftUI

struct BackgroundView: View {
    let style: BackgroundStyle
    let isAnimating: Bool

    var body: some View {
        switch style {
        case .solid(let color):
            color.ignoresSafeArea()
        case .mesh(let colors):
            MeshGradient(width: 3, height: 3, points: MeshPoints.points(at: 0), colors: colors)
                .ignoresSafeArea()
        }
    }
}
```

- [ ] **Step 3: Use it in ClockScreen**

```swift
// real-time/Clock/ClockScreen.swift
import SwiftUI

struct ClockScreen: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        ZStack {
            BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
            Text(settings.theme.name)
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
    }
}
```

- [ ] **Step 4: Build and verify both background kinds**

Run the standard build command, then launch.
Expected: a black full-bleed background ("Midnight"). Then temporarily change `ThemeCatalog.default` to `all[2]` ("Ember"), rebuild, and confirm a warm gradient fills the screen **with no visible seams or flat corners** — this is the corner-pinning check. Revert `default` to `all[0]` before committing.

- [ ] **Step 5: Commit**

```bash
git add real-time/Models/MeshPoints.swift real-time/Background/BackgroundView.swift real-time/Clock/ClockScreen.swift
git commit -m "feat: add mesh control-point geometry and static background rendering"
```

**Implementation note — corner pinning was not sufficient.**

The plan pinned only the four corner indices (0, 2, 6, 8). Building that
produced dark wedges along all four screen edges: the *edge midpoints*
(1, 3, 5, 7) were free in both axes, so moving index 1 off `y = 0` bowed the
top boundary inward and left undefined color above it. A `MeshGradient`'s
outer boundary is the drawn region, so any point leaving its edge shrinks the
mesh below the screen bounds — the same failure the plan's check was written
to catch, one ring further in.

`MeshPoints` now uses a per-axis `freedom` mask instead of a set of pinned
indices: corners are fixed in both axes, edge midpoints may slide **along**
their own edge only, and the centre point alone is free in both. The gradient
still animates; the boundary can no longer move.


---

### Task 4: The clock face

**Files:**
- Create: `real-time/Clock/ClockFace.swift`
- Modify: `real-time/Clock/ClockScreen.swift`

**Interfaces:**
- Consumes: `Theme`, `ForegroundStyle`
- Produces: `ClockFace(theme: Theme, timeZone: TimeZone)`; `ClockFace.verbatimFormat(for: TimeZone) -> Date.VerbatimFormatStyle`

- [ ] **Step 1: Create the clock face**

```swift
// real-time/Clock/ClockFace.swift
import SwiftUI

struct ClockFace: View {
    let theme: Theme
    let timeZone: TimeZone

    var body: some View {
        // 1Hz. Deliberately NOT nested inside the 30fps background.
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 28) {
                timeText(for: context.date)
                Text(Self.cityName(for: timeZone))
                    .font(.system(size: 44, weight: .medium, design: .rounded))
                    .foregroundStyle(labelColor.opacity(0.75))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Self.spokenTime(context.date, in: timeZone))
        }
    }

    @ViewBuilder
    private func timeText(for date: Date) -> some View {
        let string = date.formatted(Self.verbatimFormat(for: timeZone))
        switch theme.foreground {
        case .solid(let color):
            Text(string)
                .font(.system(size: 220, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        case .glass:
            // Replaced by GlassClockText in Task 6.
            Text(string)
                .font(.system(size: 220, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
    }

    private var labelColor: Color {
        if case .solid(let color) = theme.foreground { return color }
        return .white
    }

    /// Verbatim rather than DateFormatter: it is a value type so it is cheap
    /// to build per render, and it is explicitly 24-hour zero-based so no
    /// locale can substitute 12-hour behaviour or non-Latin digits.
    static func verbatimFormat(for timeZone: TimeZone) -> Date.VerbatimFormatStyle {
        .verbatim(
            "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
            timeZone: timeZone,
            calendar: .current
        )
    }

    static func cityName(for timeZone: TimeZone) -> String {
        timeZone.identifier
            .split(separator: "/")
            .last
            .map { $0.replacingOccurrences(of: "_", with: " ") } ?? timeZone.identifier
    }

    static func spokenTime(_ date: Date, in timeZone: TimeZone) -> String {
        date.formatted(.dateTime.hour().minute().second().timeZone())
    }
}
```

- [ ] **Step 2: Compose it into ClockScreen**

```swift
// real-time/Clock/ClockScreen.swift
import SwiftUI

struct ClockScreen: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        ZStack {
            // Siblings, never nested: background ticks at 30fps, clock at 1Hz.
            BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
            ClockFace(theme: settings.theme, timeZone: settings.timeZone)
        }
    }
}
```

- [ ] **Step 3: Build and verify the tick**

Run the standard build command, then launch.
Expected: large white `HH:MM:ss` on black with the local city name beneath. Watch for 10 seconds and confirm the seconds increment once per second and that **the digits do not shift horizontally** as they change — that is the `.monospacedDigit()` check.

- [ ] **Step 4: Commit**

```bash
git add real-time/Clock/ClockFace.swift real-time/Clock/ClockScreen.swift
git commit -m "feat: add clock face with 24-hour verbatim formatting and timezone label"
```

---
### Task 5: Animated mesh background

**Files:**
- Create: `real-time/Background/AnimatedMeshBackground.swift`
- Modify: `real-time/Background/BackgroundView.swift`

**Interfaces:**
- Consumes: `MeshPoints.points(at:amplitude:)`
- Produces: `AnimatedMeshBackground(colors: [Color], isAnimating: Bool)`

- [ ] **Step 1: Create the animated background**

```swift
// real-time/Background/AnimatedMeshBackground.swift
import SwiftUI

struct AnimatedMeshBackground: View {
    let colors: [Color]
    let isAnimating: Bool

    var body: some View {
        // 30fps, not 60: the motion is slow enough to be visually identical
        // while halving GPU work on a display meant to stay on for hours.
        // `paused:` rather than swapping views, so the mesh still renders
        // when animation is off instead of showing a different view.
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isAnimating)) { context in
            let elapsed = isAnimating ? context.date.timeIntervalSinceReferenceDate : 0
            MeshGradient(
                width: 3,
                height: 3,
                points: MeshPoints.points(at: elapsed),
                colors: colors
            )
            .ignoresSafeArea()
        }
    }
}
```

- [ ] **Step 2: Route mesh backgrounds through it, honouring Reduce Motion**

```swift
// real-time/Background/BackgroundView.swift
import SwiftUI

struct BackgroundView: View {
    let style: BackgroundStyle
    let isAnimating: Bool

    // Continuous background motion is exactly what this setting exists for.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        switch style {
        case .solid(let color):
            color.ignoresSafeArea()
        case .mesh(let colors):
            AnimatedMeshBackground(colors: colors, isAnimating: isAnimating && !reduceMotion)
        }
    }
}
```

- [ ] **Step 3: Build and verify the motion**

Run the standard build command. Temporarily set `ThemeCatalog.default` to `all[2]` ("Ember") and launch.
Expected: the gradient drifts continuously and organically, with **no visible loop point over 60 seconds** (the detuned-frequency check) and **no hard edges or flat corners** at screen borders. Then set `isAnimated` default to `false` in `AppSettings.init`, rebuild, and confirm the gradient is static but still shows all three Ember colors. Revert both temporary changes before committing.

- [ ] **Step 4: Commit**

```bash
git add real-time/Background/
git commit -m "feat: animate mesh background at 30fps with reduce-motion support"
```

---

### Task 6: Glass glyphs — spike, then implement

This is the one task whose outcome is not known in advance. Work the strategies in order and stop at the first that passes.

**Files:**
- Create: `real-time/Foreground/GlassClockText.swift`
- Modify: `real-time/Clock/ClockFace.swift`
- Modify: `docs/superpowers/plans/2026-08-24-tvos-clock.md` (record which strategy won)

**Interfaces:**
- Consumes: nothing
- Produces: `GlassClockText(text: String, fontSize: CGFloat)`

**Pass criteria:** the animated mesh must be visibly moving *through* the digits, and the time must remain readable at typical TV viewing distance.

- [ ] **Step 1: Implement Strategy A — masked glass layer**

```swift
// real-time/Foreground/GlassClockText.swift
import SwiftUI

struct GlassClockText: View {
    let text: String
    let fontSize: CGFloat

    // Glass is unreadable for users who have asked for less transparency.
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var font: Font {
        .system(size: fontSize, weight: .semibold, design: .rounded)
    }

    var body: some View {
        if reduceTransparency {
            label.foregroundStyle(.white)
        } else {
            // Text is not a Shape, so glassEffect cannot take glyph geometry
            // directly. The hidden Text supplies layout; the overlay fills
            // that frame with glass and masks it to the glyphs.
            label
                .hidden()
                .overlay {
                    GlassEffectContainer {
                        Rectangle()
                            .glassEffect(.clear, in: .rect)
                    }
                    .mask { label }
                }
        }
    }

    private var label: some View {
        Text(text)
            .font(font)
            .monospacedDigit()
    }
}
```

- [ ] **Step 2: Wire it into ClockFace**

Replace the `.glass` branch of `timeText(for:)`:

```swift
        case .glass:
            GlassClockText(text: string, fontSize: 220)
```

And update `labelColor` to stay as-is (`.white` for glass themes) — no change needed.

- [ ] **Step 3: Build, run, and screenshot Strategy A**

```bash
cd "/Users/evachlpikova/Documents/Moje projekty/real-time"
xcrun simctl boot "Apple TV 4K (3rd generation)" 2>/dev/null || true
xcodebuild -project real-time.xcodeproj -scheme real-time \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  -derivedDataPath .build build 2>&1 | tail -3
xcrun simctl install booted ".build/Build/Products/Debug-appletvsimulator/real-time.app"
xcrun simctl launch booted app.eviseek.real-time
xcrun simctl io booted screenshot /tmp/glass-strategy-a.png
```

Set `ThemeCatalog.default` to `all[4]` ("Aurora", a glass theme) for this task's verification.
Expected outcome to judge: glyph interiors show the moving mesh. If the digits render as flat white, fully invisible, or a solid rectangle of glass, Strategy A has failed — proceed to Step 4. If they show the mesh and stay readable, skip to Step 6.

- [ ] **Step 4: If A failed — Strategy B, material foreground**

Materials are valid `ShapeStyle`s, so this is guaranteed to compile and render. Replace the non-reduce-transparency branch:

```swift
            label
                .foregroundStyle(.ultraThinMaterial)
```

Rebuild and screenshot as `/tmp/glass-strategy-b.png` using the commands from Step 3.
Expected: frosted glyphs with the background genuinely visible through them. Less liquid than A, but honest glass. If readable, this is the answer — go to Step 6.

- [ ] **Step 5: If B failed — Strategy C, vibrancy blend**

```swift
            label
                .foregroundStyle(.white.opacity(0.35))
                .blendMode(.overlay)
```

Rebuild and screenshot as `/tmp/glass-strategy-c.png`. Expected: glyphs that lighten whatever is behind them without a solid fill.

- [ ] **Step 6: Record the outcome in this plan**

Append a short note under this task stating which strategy was used and why the earlier ones were rejected, referencing the screenshot paths. Report the screenshot to the user rather than asserting success.

- [ ] **Step 7: Revert the temporary default and commit**

Restore `ThemeCatalog.default` to `all[0]`.

```bash
git add real-time/Foreground/GlassClockText.swift real-time/Clock/ClockFace.swift real-time/Models/ThemeCatalog.swift docs/superpowers/plans/2026-08-24-tvos-clock.md
git commit -m "feat: add liquid-glass clock glyphs with reduce-transparency fallback"
```

---

### Task 7: Auto-hiding settings overlay and theme grid

**Files:**
- Create: `real-time/Settings/SettingsOverlay.swift`
- Create: `real-time/Settings/ThemeGrid.swift`
- Create: `real-time/Settings/ThemeTile.swift`
- Modify: `real-time/Clock/ClockScreen.swift`

**Interfaces:**
- Consumes: `AppSettings`, `ThemeCatalog.all`, `Theme`, `BackgroundView`, `ClockFace`
- Produces: `SettingsOverlay()`, `ThemeGrid()`, `ThemeTile(theme: Theme, isSelected: Bool)`

- [ ] **Step 1: Create the tile, rendering a live miniature**

The tile shows the real background and real foreground, so a tile cannot drift from the actual result.

```swift
// real-time/Settings/ThemeTile.swift
import SwiftUI

struct ThemeTile: View {
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Static preview: tiles must not run 30fps animations each.
                BackgroundView(style: theme.background, isAnimating: false)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                previewText
            }
            .frame(height: 160)

            HStack(spacing: 8) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(theme.name)
            }
            .font(.callout)
        }
    }

    @ViewBuilder
    private var previewText: some View {
        switch theme.foreground {
        case .solid(let color):
            Text("12:04")
                .font(.system(size: 46, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
        case .glass:
            GlassClockText(text: "12:04", fontSize: 46)
        }
    }
}
```

- [ ] **Step 2: Create the theme grid**

```swift
// real-time/Settings/ThemeGrid.swift
import SwiftUI

struct ThemeGrid: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 320), spacing: 40)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(ThemeCatalog.all) { theme in
                    Button {
                        settings.themeID = theme.id
                        dismiss()
                    } label: {
                        ThemeTile(theme: theme, isSelected: theme.id == settings.themeID)
                    }
                    // Apple's standard tvOS tile treatment. Focus appearance
                    // is not optional on tvOS.
                    .buttonStyle(.card)
                }
            }
            .padding(60)
        }
    }
}
```

- [ ] **Step 3: Create the overlay bar**

```swift
// real-time/Settings/SettingsOverlay.swift
import SwiftUI

struct SettingsOverlay: View {
    @Environment(AppSettings.self) private var settings
    @State private var showingThemes = false
    @State private var showingTimeZones = false

    var body: some View {
        VStack {
            HStack(spacing: 32) {
                Button("Theme") { showingThemes = true }
                Button("Timezone") { showingTimeZones = true }
                animationButton
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
            .background(.thinMaterial, in: Capsule())
            .padding(.top, 40)

            Spacer()
        }
        .fullScreenCover(isPresented: $showingThemes) { ThemeGrid() }
        .fullScreenCover(isPresented: $showingTimeZones) { TimeZonePicker() }
    }

    @ViewBuilder
    private var animationButton: some View {
        let supportsAnimation = settings.theme.background.isMesh

        VStack(spacing: 4) {
            Button(settings.isAnimated ? "Animation: On" : "Animation: Off") {
                settings.isAnimated.toggle()
            }
            // Shown disabled rather than hidden, so the control does not
            // appear and vanish as the user browses themes.
            .disabled(!supportsAnimation)

            if !supportsAnimation {
                Text("Solid themes have nothing to flow")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

- [ ] **Step 4: Add reveal-and-auto-hide to ClockScreen**

```swift
// real-time/Clock/ClockScreen.swift
import SwiftUI

struct ClockScreen: View {
    @Environment(AppSettings.self) private var settings

    @State private var isOverlayVisible = false
    /// Incremented on every remote press; drives the auto-hide timer restart.
    @State private var revealCount = 0

    var body: some View {
        ZStack {
            // Siblings, never nested: background ticks at 30fps, clock at 1Hz.
            BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
            ClockFace(theme: settings.theme, timeZone: settings.timeZone)

            if isOverlayVisible {
                SettingsOverlay()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .focusable()
        .onMoveCommand { _ in reveal() }
        .onPlayPauseCommand { reveal() }
        .onTapGesture { reveal() }
        .onExitCommand { withAnimation { isOverlayVisible = false } }
        // .task(id:) restarts the 5s countdown on every reveal and cancels
        // itself automatically — no manual Task bookkeeping.
        .task(id: revealCount) {
            guard isOverlayVisible else { return }
            try? await Task.sleep(for: .seconds(5))
            withAnimation { isOverlayVisible = false }
        }
        .animation(.easeInOut(duration: 0.25), value: isOverlayVisible)
    }

    private func reveal() {
        isOverlayVisible = true
        revealCount += 1
    }
}
```

- [ ] **Step 5: Build and verify the interaction**

Run the standard build command, then launch.
Expected, in order: clock alone with no chrome; pressing any direction on the remote slides the bar in; the bar disappears ~5 seconds after the last press; pressing again while visible restarts the 5 seconds rather than hiding it; "Theme" opens the grid; selecting a theme changes the live clock immediately and dismisses; selecting "Midnight" leaves the Animation button visibly **disabled with its caption**; Menu dismisses the bar.

- [ ] **Step 6: Commit**

```bash
git add real-time/Settings/ real-time/Clock/ClockScreen.swift
git commit -m "feat: add auto-hiding settings overlay and theme selection grid"
```

---

### Task 8: Searchable timezone picker

**Files:**
- Create: `real-time/Settings/TimeZonePicker.swift`

**Interfaces:**
- Consumes: `AppSettings.timeZoneID`
- Produces: `TimeZonePicker()`

- [ ] **Step 1: Create the picker**

```swift
// real-time/Settings/TimeZonePicker.swift
import SwiftUI

private struct TimeZoneOption: Identifiable, Hashable {
    let id: String      // the IANA identifier
    let city: String
    let region: String

    var display: String { region.isEmpty ? city : "\(city) · \(region)" }

    init(identifier: String) {
        self.id = identifier
        let parts = identifier.split(separator: "/")
        self.city = (parts.last?.replacingOccurrences(of: "_", with: " ")) ?? identifier
        self.region = parts.count > 1
            ? parts[0].replacingOccurrences(of: "_", with: " ")
            : ""
    }
}

struct TimeZonePicker: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    /// ~600 entries, built once. Sorted by city, not raw identifier, so
    /// "Prague" is findable without knowing it lives under "Europe/".
    private static let options: [TimeZoneOption] = TimeZone.knownTimeZoneIdentifiers
        .map(TimeZoneOption.init(identifier:))
        .sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }

    private var filtered: [TimeZoneOption] {
        guard !query.isEmpty else { return Self.options }
        return Self.options.filter { $0.display.localizedCaseInsensitiveContains(query) }
    }

    private let columns = [GridItem(.adaptive(minimum: 420), spacing: 28)]

    var body: some View {
        ScrollView {
            // LazyVGrid so only visible cells are built — a flat 600-cell
            // eager grid would stall the focus engine.
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(filtered) { option in
                    Button {
                        settings.timeZoneID = option.id
                        dismiss()
                    } label: {
                        HStack {
                            if option.id == settings.timeZoneID {
                                Image(systemName: "checkmark")
                            }
                            Text(option.display)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.card)
                }
            }
            .padding(60)
        }
        .searchable(text: $query, prompt: "Search cities")
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}
```

- [ ] **Step 2: Build and verify**

Run the standard build command, then launch.
Expected: overlay → "Timezone" opens a grid of city names; scrolling is smooth with no focus stutter; typing "pra" narrows to "Prague · Europe"; selecting it dismisses and the clock's label reads "Prague" with the time shifted to that zone; a nonsense query shows the empty-search view.

- [ ] **Step 3: Commit**

```bash
git add real-time/Settings/TimeZonePicker.swift
git commit -m "feat: add searchable timezone picker over all IANA zones"
```

---

### Task 9: Screensaver suppression

**Files:**
- Create: `real-time/Support/IdleTimerModifier.swift`
- Modify: `real-time/Clock/ClockScreen.swift`

**Interfaces:**
- Consumes: nothing
- Produces: `View.idleTimerDisabled()`

- [ ] **Step 1: Create the modifier**

```swift
// real-time/Support/IdleTimerModifier.swift
import SwiftUI
import UIKit

/// A clock with no remote input is idle by definition, so without this the
/// tvOS screensaver covers it. Set on appear/disappear rather than once at
/// launch, so the flag is not held for the app's whole lifetime.
private struct IdleTimerDisabledModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}

extension View {
    func idleTimerDisabled() -> some View {
        modifier(IdleTimerDisabledModifier())
    }
}
```

- [ ] **Step 2: Apply it to ClockScreen**

Add to the modifier chain on `ClockScreen`'s `ZStack`, after `.animation(...)`:

```swift
        .idleTimerDisabled()
```

- [ ] **Step 3: Build and verify**

Run the standard build command, then launch.
Expected: `** BUILD SUCCEEDED **` and the clock renders as before. The screensaver behaviour itself is impractical to verify on a simulator; confirm on a real Apple TV if one is available, otherwise accept the API contract.

- [ ] **Step 4: Commit**

```bash
git add real-time/Support/IdleTimerModifier.swift real-time/Clock/ClockScreen.swift
git commit -m "feat: prevent tvOS screensaver while the clock is visible"
```

---

## Plan Self-Review

**Spec coverage:**

| Spec requirement | Task |
|---|---|
| `HH:MM:ss` 24-hour display, 1Hz | 4 |
| Timezone label | 4 |
| Timezone switching, searchable, all IANA zones | 8 |
| Paired themes (background + foreground) | 1, 7 |
| Solid backgrounds | 3 |
| MeshGradient backgrounds, corners pinned | 3 |
| Animation toggle, mesh-only, disabled with caption | 5, 7 |
| Liquid-glass glyph foreground | 6 |
| Auto-hiding settings entry | 7 |
| Screensaver suppression | 9 |
| Persistence of theme / zone / animation | 2 |
| Theme-ID fallback | 1 |
| Reduce Motion | 5 |
| Reduce Transparency | 6 |
| Accessibility label for spoken time | 4 |

No spec requirement is unassigned.

**Known deviations from the spec, deliberate:**

- Spec lists `MeshPoints` under the rendering section; the plan places the
  file in `Models/` since it is pure geometry with no SwiftUI dependency.
- `ThemeCatalog.default` is temporarily repointed during Tasks 3, 5, and 6
  to verify non-default themes, and reverted before each commit. This is
  called out in the steps rather than left implicit.

**Type consistency:** `BackgroundView(style:isAnimating:)`,
`ClockFace(theme:timeZone:)`, `GlassClockText(text:fontSize:)`,
`AnimatedMeshBackground(colors:isAnimating:)`,
`ThemeTile(theme:isSelected:)`, and
`MeshPoints.points(at:amplitude:)` are used with identical labels at every
call site across Tasks 3–8. `BackgroundView` is introduced in Task 3 with
the `isAnimating` parameter already present, so Task 5 changes only its
internals and no call site.

**Verification-strategy note:** the plan substitutes build-and-observe steps
for the skill's default TDD cycle, per the standing "no tests unless
confirmed" preference. The three unit-testable seams are listed in the
spec's Testing section if that preference changes.
