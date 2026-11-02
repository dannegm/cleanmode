# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Optional donation reminder (PayPal) after every 10 cleanings ended by the user. Dismissible, with a "Don't remind me again" option; configurable with `donationReminderEvery`.

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
