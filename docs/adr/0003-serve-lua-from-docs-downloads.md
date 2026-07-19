# Serve plugin `.lua` files from `docs/downloads/` instead of `raw.githubusercontent.com`

Plugin `.lua` files are copied into `docs/downloads/` by CI before the MkDocs build, so they are served from the same origin as the docs site (`veaf.github.io`). Download buttons point to this relative path and carry the `download` attribute, guaranteeing a native browser file download in all browsers.

## Problem

The HTML `download` attribute is silently ignored by Chrome (and Chromium-based browsers) when the link points to a cross-origin URL, even if CORS headers are present. `raw.githubusercontent.com` is a different origin from `veaf.github.io`: clicking the button was opening the file in the browser instead of downloading it.

## Alternatives considered

- **`download` attribute on the raw URL**: ignored by Chrome for cross-origin links — the problem persists.
- **Link to the GitHub blob page (`/blob/`)**: requires two clicks; the mission maker lands on the GitHub UI before being able to download.
- **Package `.lua` as a GitHub Release asset**: requires a dedicated release workflow and adds disproportionate operational complexity.

## Consequences

- `.lua` files are duplicated in the built site (negligible size).
- Branch coherence is automatic: CI copies the files from the branch currently being built.
- The existing `sed` branch-injection step in `docs.yml` no longer applies to `.lua` download URLs (harmless: these URLs are now relative paths).
