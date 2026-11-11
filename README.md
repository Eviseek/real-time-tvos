# real-time

A full-screen clock for Apple TV. It shows the time in large digits that stay
readable from across the room, and it is meant to stay on screen for hours.

## Features

- **24-hour or 12-hour time.** The clock updates every second, and the 12-hour
  clock shows an AM/PM marker.
- **Any time zone.** Pick from every IANA zone, with search. A label shows
  which zone is active.
- **Curated themes** in six moods: Basics, Night, Daylight, Happiness, Calm and
  Storm.
  Each one is a solid colour or a mesh gradient.
- **Moving backgrounds.** Mesh gradients drift slowly, like a lava lamp. You
  can turn this off.
- **Clock colour.** White, Black, or Liquid glass (the background shows
  through the digits).
- **A settings bar that gets out of the way.** It fades after five seconds
  without input and comes back as soon as you touch the remote.
- **No screensaver** while the clock is on screen
- Your choices are saved and restored the next time the app opens

## Requirements

- Xcode 26 or later
- tvOS 26.0 or later. `glassEffect` needs tvOS 26.
- No third-party dependencies

## Build and run

Open `real-time.xcodeproj` in Xcode, pick an Apple TV simulator, and run it.

You can also build from the command line:

```bash
xcodebuild -project real-time.xcodeproj -scheme real-time \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  build
```

## Project layout

```
real-time/
├── Library/     Reusable code with no screen of its own, grouped by kind:
│                Enums, Extensions, Modifiers, Views, LiquidGlassText
├── Models/      Domain types, one subfolder per domain (Settings, Theme, TimeZone)
├── Views/       One subfolder per screen (Clock, Settings, ThemePicker,
│                TimeZonePicker)
└── Resources/   Asset catalogs
```

The project uses a file-system synchronized group, so any `.swift` file you add
under `real-time/` joins the target automatically.

## Contributing

Code conventions are in [`CLAUDE.md`](CLAUDE.md): one type per file, no magic
numbers, view bodies of 30 lines or fewer, and dependencies used through
protocols.
