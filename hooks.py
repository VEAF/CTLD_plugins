"""
MkDocs hook: add target and rel attributes to external links.

- External links get target="ext-{stable-id}" so that multiple clicks
  on the same URL reuse the same browser tab instead of opening new ones.
- Internal links (same site) are left untouched.
"""

import re
import urllib.parse


def _url_target(href: str) -> str:
    """Return a stable, sanitised target name derived from the URL."""
    parsed = urllib.parse.urlparse(href)
    raw = (parsed.netloc + parsed.path).strip("/")
    safe = re.sub(r"[^a-zA-Z0-9]", "-", raw)
    safe = re.sub(r"-{2,}", "-", safe).strip("-")
    return "ext-" + safe[:48]


def on_page_content(html, page, config, **kwargs):
    site = config.get("site_url", "")

    def process(match):
        tag = match.group(0)
        attrs = match.group(1)

        href_m = re.search(r'href="([^"]*)"', attrs)
        if not href_m:
            return tag

        href = href_m.group(1)

        # Skip non-HTTP links and links to the same site
        if not href.startswith(("http://", "https://")):
            return tag
        if site and href.startswith(site):
            return tag

        # Skip if target is already set
        if "target=" in attrs:
            return tag

        target = _url_target(href)
        return f'<a {attrs} target="{target}" rel="noopener">'

    return re.sub(r"<a ([^>]+)>", process, html)
