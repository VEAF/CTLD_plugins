# Plugin README as documentation source of truth

Each plugin has a `plugins/{name}/README.md` (YAML front-matter + French prose) that is the single source of truth for its documentation. The files `docs/plugins/{name}.md` and `{name}.fr.md` are **generated** by an interactive Claude skill — never edited by hand.

## Alternatives considered

- **Separate `meta.yaml` + prose in `docs/`**: two files to keep in sync, risk of divergence.
- **Metadata embedded in the `.lua`**: the `.lua` runs inside DCS — embedding GitHub URLs there pollutes runtime code with pure documentary metadata that has no value at execution time.

## Consequences

- `docs/plugins/` files must be regenerated after every change to a plugin's `README.md`.
- `plugins/_template/README.md` is the authoritative template for plugin authors.
- The FR→EN translation is produced by Claude on demand from the designer (interactive), not by CI.
