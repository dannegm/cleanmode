# Releasing

How to publish a new version. Right now releases are **universal (arm64 + x86_64), ad hoc signed and not notarized**, so users see a Gatekeeper warning and have to re-grant the Accessibility permission after each update (both documented in the README and in `.github/release-notice.md`, which becomes the release description). The notarization steps below remove it, but need a paid Apple Developer account.

## 1. Prepare

1. Bump `CFBundleShortVersionString` (and `CFBundleVersion`) in `Resources/Info.plist`.
2. Move the **Unreleased** notes in `CHANGELOG.md` under the new version.
3. Build and test by hand (`./scripts/build-app.sh`, `open build/CleanMode.app --args --timeout=1`), using the checklist in `CONTRIBUTING.md`.

## 2. Publish

```bash
git tag v1.0.0
git push origin v1.0.0
```

The `Release` workflow builds on a macOS runner, runs `scripts/package.sh` and attaches `CleanMode-<version>.zip` and its `.sha256` to a GitHub Release with auto-generated notes. You can also run `./scripts/package.sh` locally and upload `build/CleanMode-<version>.zip` yourself.

## 3. (Optional) Sign and notarize

This removes the Gatekeeper warning. It needs a **Developer ID Application** certificate. An "Apple Development" certificate is not enough. These steps haven't been exercised in this repo yet, so treat them as a starting point.

```bash
# One-time: store notarization credentials in the keychain
xcrun notarytool store-credentials "notary" --apple-id YOU@EXAMPLE.COM --team-id TEAMID --password APP_SPECIFIC_PASSWORD

# Build; build-app.sh adds hardened runtime + timestamp for "Developer ID" identities
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-app.sh

# Notarize and staple, then zip
ditto -c -k --keepParent build/CleanMode.app build/notarize.zip
xcrun notarytool submit build/notarize.zip --keychain-profile "notary" --wait
xcrun stapler staple build/CleanMode.app
ditto -c -k --keepParent build/CleanMode.app build/CleanMode-1.0.0.zip
shasum -a 256 build/CleanMode-1.0.0.zip
```

To automate this in CI, store the certificate (base64 `.p12`) and notarization credentials as repository secrets and add the import/notarize steps to `.github/workflows/release.yml`.

## 4. (Optional) Homebrew cask

Once releases are stable, a cask in your own tap (for example `homebrew-tap/Casks/clean-mode.rb`) lets people run `brew install --cask clean-mode`:

```ruby
cask "clean-mode" do
  version "1.0.0"
  sha256 "SHA256_OF_THE_ZIP"

  url "https://github.com/YOUR_GITHUB_USER/cleanmode/releases/download/v#{version}/CleanMode-#{version}.zip"
  name "Clean Mode"
  desc "Lock the keyboard and screen while you clean your Mac"
  homepage "https://github.com/YOUR_GITHUB_USER/cleanmode"

  depends_on macos: ">= :ventura"

  app "CleanMode.app"

  zap trash: []
end
```

## Placeholders to replace

Search the repo for `YOUR_GITHUB_USER` (README, this file, `.github/release-notice.md`, issue template config) and replace it with the real GitHub user or organization once the repository exists.
