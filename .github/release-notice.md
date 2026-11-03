## Install

1. Download `CleanMode-<version>.zip`, unzip it and move **CleanMode.app** to `/Applications`.
2. Open it. The first time, macOS will warn that it can't verify the app (see below).
3. Follow the on-screen steps to grant the **Accessibility** permission. Clean Mode starts by itself once it's active.

## Things to know

- **Universal build**: runs natively on Apple Silicon and Intel Macs, macOS 13 or later.
- **Not notarized.** The app is free and open source and is signed ad hoc (no paid Apple Developer account), so Gatekeeper shows *"Apple could not verify…"*. To open it: **System Settings → Privacy & Security → Open Anyway**, or run:
  ```bash
  xattr -dr com.apple.quarantine /Applications/CleanMode.app
  ```
- **Updates ask for the Accessibility permission again.** Because the signature is ad hoc, macOS treats every new version as a different app. Remove the old "Clean Mode" entry (− button) and turn on the new one.
- **Verify your download** (optional): `shasum -a 256 -c CleanMode-<version>.zip.sha256`.
- **Website**: [cleanmode.hckr.mx](https://cleanmode.hckr.mx).
- **Privacy**: it never logs or sends what you type and makes no network requests. The source is in this repository.
- The **translations** were not reviewed by native speakers. Corrections are welcome!
- **Donations**: Clean Mode is free. If it's useful, you can [donate with PayPal](https://www.paypal.me/dannegm). A small, dismissible reminder appears after every 10 cleanings you end yourself (it has a "Don't show again" button and can be turned off with `defaults write im.dnn.cleanmode donationReminderEvery -int 0`).

See [CHANGELOG.md](https://github.com/dannegm/cleanmode/blob/main/CHANGELOG.md) for what changed.
