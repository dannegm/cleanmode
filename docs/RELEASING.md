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

  url "https://github.com/dannegm/cleanmode/releases/download/v#{version}/CleanMode-#{version}.zip"
  name "Clean Mode"
  desc "Lock the keyboard and screen while you clean your Mac"
  homepage "https://github.com/dannegm/cleanmode"

  depends_on macos: ">= :ventura"

  app "CleanMode.app"

  zap trash: []
end
```

## Landing page (Vercel)

The website lives in `landing/` (React + Vite, pnpm) and is deployed on Vercel. Its download button points to `https://github.com/dannegm/cleanmode/releases/latest`, so it never needs updating when you publish a release.

One-time setup:

1. In Vercel: **Add New → Project**, import `dannegm/cleanmode`.
2. Set **Root Directory** to `landing` (Vercel can't read this from `vercel.json`). The framework (Vite), install command (`pnpm install`), build command and output directory (`dist`) come from `landing/vercel.json`.
3. Deploy. The site rebuilds on every push; `ignoreCommand` in `vercel.json` skips the build when nothing inside `landing/` changed (for example, Swift-only commits).
4. Add the domain **`cleanmode.hckr.mx`** under **Settings → Domains**, and create the DNS record Vercel shows for it (for a subdomain, a `CNAME` for `cleanmode` pointing to `cname.vercel-dns.com`). The canonical URL, the Open Graph tags, `robots.txt` and `sitemap.xml` already use this domain.

Notes:

- Commit `landing/pnpm-lock.yaml` (run `pnpm install` once inside `landing/`) so Vercel installs the exact versions.
- `vercel.json` sets `ENABLE_EXPERIMENTAL_COREPACK=1` so Vercel uses the pnpm version declared in `package.json` (`packageManager`). If you bump pnpm locally, update that field too.
- If pnpm complains about ignored build scripts, approve them with `pnpm approve-builds`.
- The domain is hard-coded in `landing/index.html`, `landing/public/robots.txt` and `landing/public/sitemap.xml`. If it ever changes, update those three files. Also set the repository's **Website** field (About → ⚙) on GitHub to `https://cleanmode.hckr.mx`.
