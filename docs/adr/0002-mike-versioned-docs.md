# Versioned docs site with mike (latest / dev)

The MkDocs Material site is managed by **mike**, with two versions coexisting on GitHub Pages: `latest` (branch `master`) and `dev` (branch `develop`). Each version injects its own `{branch}` value into download buttons, ensuring that a tester on `dev` downloads the `.lua` from `develop` and not from `master`.

## Alternatives considered

- **Single site (master only)**: impossible to test the docs and download links in staging without workarounds — the tester would have clicked "download" and received the stable version, not the one under test.
- **Two separate sites (`/` and `/dev/`)**: works but loses the built-in version selector, already validated in the VEAF org (`veaf.github.io/documentation/`).

## Site URLs

| Version | URL | Trigger |
| ------- | --- | ------- |
| Production (`latest`) | <https://veaf.github.io/CTLD_plugins/latest/> | push to `master` |
| Staging (`dev`) | <https://veaf.github.io/CTLD_plugins/dev/> | push to `develop` |
| Root | <https://veaf.github.io/CTLD_plugins/> | redirects to `latest` |

## Consequences

- The `docs.yml` workflow calls `mike deploy dev` on push to `develop` and `mike deploy latest` on push to `master`.
- `{branch}` is a variable injected at doc generation time (Claude skill) — value is `develop` or `master`.
- The `versions.json` managed by mike must stay on `gh-pages`, not committed to `develop`/`master`.
