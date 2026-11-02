# Contributing to Clean Mode

Thanks for helping! This is a small app, so contributing is simple.

## Ground rules

- **Privacy is a feature.** Clean Mode must never log, store or send keystrokes, and must not make network requests. Pull requests that add either will be declined.
- **Safety first.** There must always be a way out. Don't remove or weaken the three exits (hold button, ⌘Q ×3, timeout) and don't make the lock outlive the process.
- Be kind. See the [Code of Conduct](CODE_OF_CONDUCT.md).

## Setup

You need macOS 13+ and Swift 5.9+. See [Build from source](README.md#build-from-source).

```bash
./scripts/build-app.sh
open build/CleanMode.app --args --timeout=1
```

**Always test with a short `--timeout`**: the app captures the keyboard and screen. If you get stuck, press ⌘Q three times or hold the on-screen button.

Since the Accessibility permission is tied to the code signature, sign with your own certificate (`CODESIGN_IDENTITY=…`) so you don't have to re-grant it after every build.

## There are no automated tests

Please test your change by hand and say what you checked in the pull request. A useful checklist:

- [ ] First launch without the permission shows the onboarding, and the lock starts once it's granted.
- [ ] Keyboard, media keys and shortcuts are blocked; the mouse and the exit button still work.
- [ ] All three exits work (hold button, ⌘Q ×3, timeout).
- [ ] Works with more than one display.
- [ ] Looks right in a right-to-left language (`--lang=ar`) and a long one (`--lang=de`).

If you change the UI, regenerate the README screenshots: `build/CleanMode.app/Contents/MacOS/CleanMode --render-docs=docs/screenshots --lang=en` (renders to PNG, doesn't lock anything).

## Code style

- Follow the existing style: small files, one responsibility each, comments that explain *why*.
- Strings must be localized (see below); never hard-code user-facing text in views.
- Keep dependencies at zero. The app only uses Apple frameworks.

## Translations

All strings live in [`Sources/CleanMode/Localization.swift`](Sources/CleanMode/Localization.swift).

- **Fix or improve a translation:** edit the string in that language's table.
- **Add a string:** add the key to `en` first (it's the source of truth), then to every other language.
- **Add a language:** add its code to `L10n.supported`, create its table, register it in `tables`, and add it to `CFBundleLocalizations` in `Resources/Info.plist`. If it's right-to-left, add it to `rightToLeft`.
- Templates use `{keys}` where the ⌘ and Q key chips should appear, and `%d` / `%@` for numbers and text. Plurals use the `.one` / `.two` / `.other` suffixes.
- Try it with `open build/CleanMode.app --args --timeout=1 --lang=xx`.

Several translations were written without native review, so corrections are especially welcome.

## Pull requests

1. Fork and create a branch from `main`.
2. Keep the change focused. One topic per PR.
3. Update `CHANGELOG.md` under **Unreleased**.
4. Describe what you changed and how you tested it.

## Reporting bugs

Use the [bug report form](../../issues/new?template=bug_report.yml). Please include your macOS version, the app version and whether you installed a release or built from source.
