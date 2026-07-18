#!/usr/bin/env python3
"""
validate_docs.py — CI gate for plugin documentation coherence.

For each plugin directory under plugins/ (excluding _template):
  - WARNING  if plugins/{name}/README.md is absent
  - ERROR    if README.md is present but front-matter YAML is malformed
  - ERROR    if README.md is present and modUrls is not a list of {mod, url} pairs
  - ERROR    if docs/plugins/{name}.md or docs/plugins/{name}.fr.md is absent
"""

import sys
import os
import re

PLUGINS_DIR = "plugins"
DOCS_DIR = os.path.join("docs", "plugins")
TEMPLATE = "_template"

errors = []
warnings = []


def parse_frontmatter(path):
    """Return parsed front-matter dict, or None if absent/malformed."""
    with open(path, encoding="utf-8") as f:
        content = f.read()

    # Strip comment lines from inside the YAML front-matter before parsing
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    raw_yaml = match.group(1)
    # Remove YAML comment lines
    yaml_lines = [l for l in raw_yaml.splitlines() if not l.strip().startswith("#")]
    clean_yaml = "\n".join(yaml_lines)

    try:
        import yaml
        return yaml.safe_load(clean_yaml) or {}
    except Exception as e:
        return e  # signal parse error


def validate_mod_urls(mod_urls):
    """Return error message if modUrls is malformed, else None."""
    if not isinstance(mod_urls, list):
        return "modUrls must be a list"
    for i, entry in enumerate(mod_urls):
        if not isinstance(entry, dict):
            return f"modUrls[{i}] must be a dict with 'mod' and 'url' keys"
        if "mod" not in entry or "url" not in entry:
            return f"modUrls[{i}] is missing 'mod' or 'url' key"
    return None


def main():
    if not os.path.isdir(PLUGINS_DIR):
        print(f"ERROR: {PLUGINS_DIR}/ directory not found — run from repo root")
        sys.exit(1)

    plugins = [
        p for p in os.listdir(PLUGINS_DIR)
        if os.path.isdir(os.path.join(PLUGINS_DIR, p)) and p != TEMPLATE
    ]

    if not plugins:
        print("No plugins found (excluding _template) — nothing to validate.")
        sys.exit(0)

    for plugin in sorted(plugins):
        readme_path = os.path.join(PLUGINS_DIR, plugin, "README.md")
        doc_en = os.path.join(DOCS_DIR, f"{plugin}.md")
        doc_fr = os.path.join(DOCS_DIR, f"{plugin}.fr.md")

        # README absent → warning only
        if not os.path.isfile(readme_path):
            warnings.append(f"[{plugin}] README.md absent — doc pages will have no narrative prose")
        else:
            fm = parse_frontmatter(readme_path)
            if fm is None:
                errors.append(f"[{plugin}] README.md has no YAML front-matter")
            elif isinstance(fm, Exception):
                errors.append(f"[{plugin}] README.md front-matter is malformed: {fm}")
            else:
                mod_urls = fm.get("modUrls")
                if mod_urls is not None:
                    err = validate_mod_urls(mod_urls)
                    if err:
                        errors.append(f"[{plugin}] README.md modUrls invalid: {err}")

        # Generated doc pages must exist
        for doc_path in (doc_en, doc_fr):
            if not os.path.isfile(doc_path):
                errors.append(f"[{plugin}] missing generated doc: {doc_path}")

    # Report
    for w in warnings:
        print(f"WARNING: {w}")
    for e in errors:
        print(f"ERROR:   {e}")

    if errors:
        print(f"\n{len(errors)} error(s) — fix before merging.")
        sys.exit(1)
    else:
        print(f"OK — {len(plugins)} plugin(s) checked, {len(warnings)} warning(s), 0 errors.")
        sys.exit(0)


if __name__ == "__main__":
    main()
