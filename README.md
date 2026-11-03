<p align="center">
  <img src="Resources/AppIcon-1024.png" width="160" alt="Clean Mode icon">
</p>

<h1 align="center">Clean Mode</h1>

<p align="center">
  Lock your Mac's keyboard, shortcuts and screen while you clean it.<br>
  Wipe everything down without opening apps, changing settings or putting the Mac to sleep by accident.
</p>

<p align="center">
  <a href="https://github.com/dannegm/cleanmode/releases/latest"><strong>⬇️ Download for macOS</strong></a>
  &nbsp;·&nbsp;
  <a href="https://cleanmode.hckr.mx">Website</a>
  &nbsp;·&nbsp;
  <a href="#build-from-source">Build from source</a>
  &nbsp;·&nbsp;
  <a href="CONTRIBUTING.md">Contribute</a>
</p>

<p align="center">
  <img alt="macOS 13+" src="https://img.shields.io/badge/macOS-13%2B-black?logo=apple">
  <img alt="Universal: Apple Silicon and Intel" src="https://img.shields.io/badge/universal-Apple%20Silicon%20%2B%20Intel-lightgrey">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift">
  <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="13 languages" src="https://img.shields.io/badge/languages-13-green">
  <a href="https://www.paypal.me/dannegm"><img alt="Donate with PayPal" src="https://img.shields.io/badge/Donate-PayPal-00457C?logo=paypal"></a>
</p>

<p align="center">
  <img src="docs/screenshots/lock.png" alt="Clean Mode lock screen: black screen, broom icon and hold-to-exit button">
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/onboarding-dark.png">
    <img src="docs/screenshots/onboarding-light.png" width="360" alt="First-run onboarding that explains and checks the Accessibility permission">
  </picture>
</p>

<p align="center"><sub>The lock screen and the first-run onboarding.</sub></p>

---

## The problem

Cleaning a laptop is surprisingly risky. Wiping the keyboard presses every key; wiping the trackpad fires gestures; touching the screen at the wrong moment closes windows. In a few seconds you can:

- type garbage into whatever app is focused,
- trigger shortcuts (quit, close, delete, Mission Control, Spotlight…),
- change volume or brightness, or toggle settings,
- put the Mac to sleep or log out.

**And you can't just turn it off.** It's the obvious fix, but the Mac turns right back on (or wakes up) as soon as you press any key or touch the mouse or trackpad, which is exactly what you do while cleaning. Even if it stayed off, you'd be wiping a dark screen where dust is hard to see.

## What Clean Mode does

Open it and everything gets locked, while the screen stays on and black so you can see exactly where you've cleaned:

- **Keyboard locked**: every key, including media / volume / brightness keys, is swallowed.
- **Shortcuts and gestures locked**: Cmd+Tab, Cmd+Q, force quit, Dock, menu bar and most trackpad gestures are disabled.
- **Black screen on every display**, so smudges and dust are easy to spot.
- **Custom cursor**: the real cursor is hidden and replaced by a circle with a smooth trail. The mouse keeps working so you can use the exit button.
- **No need to turn the Mac off.** The display stays on and black while it's active, so there's nothing for a stray key or mouse movement to turn back on.
- **Hold-to-exit button**: hold it for 3 seconds to leave.
- **Never get stuck**: three independent ways out (below).
- **13 languages**, picked automatically from your system.

### Three ways out

| Exit | How |
| --- | --- |
| Button | Hold the on-screen button for 3 s |
| Keyboard | Press <kbd>⌘</kbd> <kbd>Q</kbd> three times (the count resets if you pause) |
| Timeout | Closes by itself after 15 minutes (configurable) |

If the app ever crashes, the keyboard lock disappears with it.

### What it can't do

Software can't block everything:

- The **power button / Touch ID key**: a long press still powers the Mac off. Avoid it while cleaning.
- **Closing the lid** puts the Mac to sleep as usual.
- A few system-level trackpad gestures may still get through on some macOS versions. If you find one, please [open an issue](../../issues).

## Install

1. Download `CleanMode-x.y.z.zip` from the [latest release](https://github.com/dannegm/cleanmode/releases/latest) and unzip it.
2. Move `CleanMode.app` to `/Applications`.
3. Open it. On first launch Clean Mode walks you through granting the **Accessibility** permission (macOS requires it to be able to block the keyboard) and starts as soon as it's active.

> **"Apple could not verify…" warning?** Releases are free, open source and **not notarized** (that requires a paid Apple Developer account), so macOS shows this warning the first time. Open **System Settings → Privacy & Security**, scroll to the message about Clean Mode and click **Open Anyway**. Or from Terminal:
> ```bash
> xattr -dr com.apple.quarantine /Applications/CleanMode.app
> ```

To verify your download, compare it with the `.sha256` file attached to the release: `shasum -a 256 -c CleanMode-x.y.z.zip.sha256`.

### Known limitations

- **Updates ask for the Accessibility permission again.** Releases are signed ad hoc, so macOS sees every version as a different app. Remove the old "Clean Mode" entry in Accessibility (− button) and turn on the new one. The onboarding guides you.
- **Not notarized**, see above.
- **Translations** haven't been reviewed by native speakers.

### Options

```bash
# Try it for one minute first
open /Applications/CleanMode.app --args --timeout=1

# Change the auto-close time (minutes; 0 or less disables it)
defaults write im.dnn.cleanmode timeoutMinutes -int 20

# Force a language
open /Applications/CleanMode.app --args --lang=ja
```

## Privacy

Clean Mode needs the Accessibility permission only to be able to intercept the keyboard and throw the keystrokes away.

- It **does not log, store or transmit** what you type. Every key is discarded; the only thing it looks at is whether you pressed ⌘Q, to count the emergency exit.
- It **makes no network requests** and has no analytics. (The optional donation reminder keeps a local counter; see [Support](#support-the-project).)
- It's open source: read `Sources/CleanMode/KeyboardBlocker.swift`.
- You can revoke the permission any time in System Settings → Privacy & Security → Accessibility.

## Languages

English, Español, 中文, हिन्दी, العربية (right-to-left), Français, Português, Русский, বাংলা, 日本語, Deutsch, Italiano, 한국어. The language follows your system preferences and falls back to English. Translations are a great first contribution, see [CONTRIBUTING.md](CONTRIBUTING.md#translations).

## Build from source

Requirements: macOS 13+, Swift 5.9+ (Xcode or the Command Line Tools). The build is a **universal binary** (Apple Silicon + Intel). Full Xcode is optional but recommended: it's used to compile the app icon catalog (`actool`).

```bash
git clone https://github.com/dannegm/cleanmode.git
cd cleanmode

./scripts/build-app.sh        # builds (universal), assembles and signs build/CleanMode.app
NATIVE_ONLY=1 ./scripts/build-app.sh   # faster dev build for this Mac's architecture only
open build/CleanMode.app --args --timeout=1
```

Notes:

- The build is **ad hoc signed** by default. macOS ties the Accessibility permission to the signature, so each rebuild asks for it again. Sign with your own certificate to keep it:
  ```bash
  CODESIGN_IDENTITY="Apple Development: Your Name (TEAMID)" ./scripts/build-app.sh
  ```
  (`security find-identity -p codesigning -v` lists your identities.)
- Reset the permission while testing the onboarding: `tccutil reset Accessibility im.dnn.cleanmode`.
- Regenerate the icon: `./scripts/make-icon.sh` (drawn with CoreGraphics in `scripts/make-icon.swift`).
- Build a release zip + checksum: `./scripts/package.sh`.
- Regenerate the README screenshots (renders the SwiftUI views to PNG; it does not lock anything): `build/CleanMode.app/Contents/MacOS/CleanMode --render-docs=docs/screenshots --lang=en`.

> ⚠️ The app takes over your keyboard and screen. Always test with a short `--timeout`.

### Website

The website, live at **[cleanmode.hckr.mx](https://cleanmode.hckr.mx)**, is in [`landing/`](landing) (React + Vite + Tailwind, English and Spanish) and uses pnpm:

```bash
cd landing
pnpm install
pnpm dev        # http://localhost:5173
pnpm build      # static site in landing/dist
```

The repository URL, download link and donation link are in `landing/src/config.js`; texts are in `landing/src/locales/`. Deployment notes: [docs/RELEASING.md](docs/RELEASING.md#landing-page-vercel).

### Project layout

| Path | What's there |
| --- | --- |
| `Sources/CleanMode/LockController.swift` | Orchestrates the lock: windows, keyboard, cursor, sleep, timeout |
| `Sources/CleanMode/KeyboardBlocker.swift` | The `CGEventTap` that swallows input and counts ⌘Q |
| `Sources/CleanMode/OverlayView.swift` | Lock screen UI and the hold-to-exit button |
| `Sources/CleanMode/CursorTrailView.swift` | Custom cursor and trail |
| `Sources/CleanMode/Onboarding*.swift`, `Permissions.swift` | Accessibility onboarding and permission checks |
| `Sources/CleanMode/Localization.swift` | All strings, 13 languages |
| `scripts/` | Build, icon and packaging scripts |
| `landing/` | The website (React + Vite + Tailwind, pnpm), deployed on Vercel |

## Support the project

Clean Mode is free and open source. If it's useful to you, you can [donate with PayPal](https://www.paypal.me/dannegm). It's entirely optional, and thank you!

**About the reminder.** After every 10 cleanings that *you* end (hold button or ⌘Q ×3), the app shows one small window asking if you'd like to donate. It never appears while the lock is active, never after an automatic close, and it has a **"Don't show again"** button. Closing the window just postpones it. The only thing stored is a counter on your Mac (the app makes no network requests; the PayPal page opens in your browser only if you click Donate).

```bash
# Change how often it appears (0 turns it off completely)
defaults write im.dnn.cleanmode donationReminderEvery -int 20
defaults write im.dnn.cleanmode donationReminderEvery -int 0
```

## Contributing

Bug reports, translations and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md). For security issues see [SECURITY.md](SECURITY.md). Maintainers: [docs/RELEASING.md](docs/RELEASING.md).

## Acknowledgements

- The cleaning-mode idea and the broom icon come from the sibling project **aura**. The icon is [Lucide](https://lucide.dev)'s `brush-cleaning` (ISC License). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- The cursor trail is inspired by the "Cascading Dots" effect in [Cursor Lab](https://cursor-lab-ui.vercel.app/).

## License

[MIT](LICENSE) © Daniel Garcia
