# Sparkle Release Setup

## GitHub Release packages

The repo also ships `.github/workflows/release-packages.yml` for GitHub-hosted packaging.

- It builds the unsigned release app on `macos-15`.
- It runs `./scripts/package-unsigned.sh` to generate both `.dmg` and `.zip`.
- It publishes those assets to the matching GitHub Release for a `v*` tag.
- It is safe to rerun after a partially failed publish; the workflow reuses the existing tag release, re-uploads assets with `--clobber`, and then updates the final draft / prerelease state.
- It does not notarize, staple, or generate Sparkle appcast assets.

Use that workflow when you want downloadable GitHub Release artifacts without the local signing / notarization toolchain. Use the flow below when you need the notarized Sparkle release path.

## One-time setup

1. Copy `Config/LocalSecrets.example.xcconfig` to `Config/LocalSecrets.xcconfig`.
2. Fill in:
   - `SPARKLE_APPCAST_URL`
   - `SPARKLE_PUBLIC_ED_KEY`
3. Generate signing keys if you have not already:

```bash
./scripts/generate-keys.sh
```

## Per-release flow

1. Create release notes at `releases/notes/<version>.md`.
   - Use `releases/notes/README.md` as the authoring template.
2. Build the app:

```bash
./scripts/build.sh
```

3. Create the notarized DMG, appcast, and release assets:

```bash
./scripts/create-release.sh
```

## Notes

- The GitHub Actions release-packaging workflow is intentionally separate from the Sparkle release flow above.
- `Config/LocalSecrets.xcconfig` is intentionally gitignored.
- `scripts/create-release.sh` will package `releases/notes/<version>.md` as `PingIsland-<version>.md`.
- The app prefers Markdown release notes and falls back to Sparkle's explicit release notes links when Markdown is unavailable.
