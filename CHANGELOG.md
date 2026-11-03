# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- Lock screen measurements are now fixed and identical on every screen (the ones calibrated for 1280×720: UI scale 1.44) instead of scaling with the screen height. The hold-to-exit button keeps its own size.
- The broom icon is vertically aligned with the title text.
- The description is now 18 pt and the auto-close countdown 16 pt (slightly transparent).

## [1.1.1]

### Fixed
- The app and the release zip reported version `1.0.0` in the 1.1.0 release, because `Info.plist` wasn't bumped. The version is now `1.1.1` (build `2`).

## [1.1.0]

### Changed
- The lock screen content is larger (UI scale 1.5). On short screens the scale reduces itself so the content, the ⌘Q hint and the footer never overlap (1280×720 uses 1.44).
- The documentation and the website now explain a key part of the problem: turning the Mac off doesn't help, because it turns right back on with any key press or mouse movement.

### Added
- Hidden `--render-size=WxH` option for the screenshot renderer (`--render-docs`), to check the layout on smaller screens.
- Website: donate section, responsive fixes (including the download section on mobile) and Vercel deployment settings.

## [1.0.0]

### Added
- Keyboard lock (including media keys), system shortcuts and gestures, with a black overlay on every display.
- Custom cursor: a circle with a smooth trail. The mouse keeps working.
- Three exits: hold-to-exit button (3 s), ⌘Q three times, and an auto-close timeout (15 min by default, configurable).
- Display stays awake while active.
- Onboarding that explains and verifies the Accessibility permission, then starts the lock automatically.
- 13 languages (en, es, zh, hi, ar, fr, pt, ru, bn, ja, de, it, ko) chosen from the system language, with right-to-left support.
- App icon, build and packaging scripts.
- Universal binary (Apple Silicon + Intel), ad hoc signed.
- Optional donation reminder (PayPal) after every 10 cleanings ended by the user. Dismissible, with a "Don't remind me again" option; configurable with `donationReminderEvery`.
