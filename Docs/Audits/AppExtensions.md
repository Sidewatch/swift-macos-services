# Audit log

Last full audit: **24 Sep 2026** — the day the package was extracted from Sidewatch's app target,
where the driver had shipped behind the Settings switch for the Quick Look preview extension and
`--selftest-quicklook`'s round-trip (read, off, on, restored). Add a dated line under *History*
when you audit again, and keep *Known non-issues* current so the next pass skips them.

## What a full audit checks

1. `swift build` warnings (none allowed except those listed under known non-issues) and `swift test` green.
2. Dead code: every `func`/type/property declared once and referenced nowhere in the package or the family.
   Public API is NOT dead because Sidewatch does not call it.
3. Every public declaration documented with `///`.
4. The README's usage sample compiles against the current API.

## Known non-issues

- `pluginkit`'s output format is undocumented; `parseState` reads the mark at the start of the line
  naming the identifier and nothing else, so a column change does not break it.
- `pluginkit` is `/usr/bin/pluginkit` on every macOS since 10.10; there is no framework equivalent.

## History

- 24 Sep 2026 — extracted; four tests, one stand-in runner.
