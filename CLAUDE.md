# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Clean Mode: a native macOS app (Swift package, macOS 13+, bundle id `im.dnn.cleanmode`) for cleaning the computer. On launch it locks the keyboard, system shortcuts and trackpad gestures, covers every display with a black overlay, hides the real cursor and draws a custom one (circle with a trail). The mouse still works so the user can hold the on-screen button to exit. Sibling projects used as visual/i18n references: `../aura` (cleaning-mode overlay, `BrushCleaning` icon, `HoldButton`) and `../tabs` (the 13-language set).

There are no tests and no linter.

## Commands

```bash
# Build (universal arm64+x86_64) + assemble + sign build/CleanMode.app (ad hoc signature by default)
./scripts/build-app.sh
# Faster dev build, this Mac's architecture only
NATIVE_ONLY=1 ./scripts/build-app.sh
# Release zip + sha256 (what CI publishes)
./scripts/package.sh
# Sign with the dev identity so the Accessibility permission survives rebuilds
CODESIGN_IDENTITY="Apple Development: Daniel Garcia (4754A3GU5N)" ./scripts/build-app.sh

# Regenerate the app icon (Resources/AppIcon.icns, AppIcon-1024.png, Assets.xcassets/AppIcon.appiconset)
./scripts/make-icon.sh
# Only the 1024px PNG (no .icns / build)
swift scripts/make-icon.swift Resources/AppIcon-1024.png

# Regenerate README screenshots (renders SwiftUI views to PNG and exits; locks nothing)
build/CleanMode.app/Contents/MacOS/CleanMode --render-docs=docs/screenshots --lang=en

# Run (it takes over keyboard and screen — always pass a short timeout when testing)
open build/CleanMode.app --args --timeout=1 --lang=ja
```

Runtime options: timeout in minutes (default 15, `<= 0` disables) via `--timeout=N`, env `CLEANMODE_TIMEOUT_MINUTES`, or `defaults write im.dnn.cleanmode timeoutMinutes -int N` (later in that list wins over earlier). Language override via `--lang=xx` or env `CLEANMODE_LANG`.

## Architecture

Flow: `main.swift` → `AppDelegate`. If `Permissions.isReady` it calls `LockController.start()`; otherwise `OnboardingController.show()`, which polls every second and calls `startLock()` once the permission is verified.

- **`LockController`** orchestrates everything and is the only place that sets/undoes global state: `KeyboardBlocker`, one `OverlayWindow` per `NSScreen` (level `CGShieldingWindowLevel`, rebuilt on screen-parameter changes), `NSApp.presentationOptions` (hides Dock/menu bar, disables Cmd+Tab, force quit, session termination), real-cursor hide (`CGDisplayHideCursor` + `NSCursor.hide`), an `IOPMAssertion` (no display sleep) and the auto-close countdown. `start()` creates the keyboard tap *first* and returns false before touching anything else if that fails.
- **`KeyboardBlocker`**: an active `CGEventTap` (session tap, head insert) that swallows keyDown/keyUp/flagsChanged, `NX_SYSDEFINED` (media keys) and gesture events. It counts Cmd+Q presses (ignoring autorepeat) with a debounce reset; the tap callback runs on the main run loop so it can call UI directly. It re-enables itself on `tapDisabledByTimeout`.
- **Three exits**, all funnel into `LockController.unlock()` → `onFinish` → terminate: hold the button (`Config.holdDuration`, 3 s), Cmd+Q ×3 (`quitPressesRequired`, `quitDebounce`), or the timeout. `AppDelegate.applicationShouldTerminate` cancels termination unless `allowTerminate` is set, so only `unlock()` can quit the app.
- **UI**: `OverlayView` (SwiftUI, hosted in `NSHostingView`) shows content only on the screen under the mouse at launch; other screens are plain black. `CursorTrailView` (AppKit, `CALayer` dots, a 60 Hz timer) sits above it and returns nil from `hitTest` so clicks reach the button. The trail records the pointer path and places each dot where the pointer was N ms ago (not a lerp chain — that read as a whip). `HoldButton` fills white and flips the label to black via a masked second label. `BrushCleaningShape` draws aura's lucide icon from SVG path data through the small parser in `SVGPath.swift`. `Config.uiScale` (1.15) scales the whole overlay.
- **`DocsRenderer`** (hidden `--render-docs=<dir>` flag, handled first thing in `AppDelegate`): draws `OverlayView` and `OnboardingView` with `ImageRenderer` into PNGs and exits without locking or asking permissions. `OverlayView(preview: true)` skips the fade-in. `ImageRenderer` can't draw AppKit-backed controls (e.g. `ProgressView` renders as a "prohibited" sign), which is why onboarding uses the pure-SwiftUI `Spinner`; the cursor trail (AppKit) doesn't appear in the screenshots.
- **Donation reminder** (`DonationReminder`, `DonationView`/`DonationController`): `AppDelegate.sessionFinished` counts each finished session (3 exit reasons via `LockController.ExitReason`) and, every `Config.donationReminderEvery` (10) sessions ended by the user (not by timeout), shows a small dismissible window before quitting. State is three local `UserDefaults` keys (`donationSessions`, `donationNextAt`, `donationOptOut`); no network. The link is `Config.donationURL`. To test: `--donation-every=1`; reset with `defaults delete im.dnn.cleanmode donationSessions donationNextAt donationOptOut`.
- **`Permissions`**: `accessibilityGranted` is the silent `AXIsProcessTrusted()`; `eventTapReady` actually tries to create a tap (only when granted, to avoid triggering system prompts). The system permission dialog is triggered *only* by the onboarding button (`requestAndOpenSettings`), never at launch.
- **`Localization.swift` (`L10n`)**: all user-facing strings live here as per-language dictionaries (13 languages, same set as `../tabs`: en es zh hi ar fr pt ru bn ja de it ko; `en` is the fallback and source of truth). The language is the first system-preferred language whose primary subtag is supported. `{keys}` in a template marks where the ⌘ and Q key chips go (`KeyHintText`), `.one/.two/.other` suffixes + `L10n.plural` handle plurals, and Arabic flips the layout (`isRTL`). To add a string: add the key to `en` first, then to every other language. Translations were written by Claude, not native speakers.

## Gotchas

- The app grabs the keyboard and screen. Don't launch it casually from a session; use `--timeout=1`. If the tap dies the keyboard returns immediately (it lives and dies with the process).
- No App Sandbox: event taps don't work in a sandbox.
- macOS ties the Accessibility grant to bundle id + signing identity. Changing `CFBundleIdentifier` or the signing identity (e.g. ad hoc rebuilds) resets it and the onboarding shows again.
- App icon: `build-app.sh` compiles `Resources/Assets.xcassets` with `actool` from `/Applications/Xcode.app` (needs the Xcode license accepted; plain Command Line Tools have no `actool`), writes `Assets.car`, and only then adds `CFBundleIconName` to the built plist. Without Xcode it falls back to `AppIcon.icns`. It also runs `lsregister -f` to refresh the icon cache.
- `sudo` doesn't work in a Claude Code session (no TTY). Admin commands can go through `osascript ... with administrator privileges`, or the user runs them in their own terminal.
- `Info.plist` lives in `Resources/` and is copied into the bundle by the build script; `CFBundleLocalizations` lists the 13 languages (declaration only — strings are in `L10n`, not `.lproj` files).
