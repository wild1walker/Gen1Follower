# Gen1Follower 1.3.1

A test-only patch. **Nothing about the mod changes** — 1.3.0's map POKéMON, the
follower, sizing and every option behave exactly as they did.

**Requires Gen1Recomp 0.1.86 or newer.**

## Install

Download `Gen1Follower-1.3.1.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`. If you already have 1.3.0 there is nothing here for
you.

## What this fixes

1.3.0 shipped the suites that check the map-POKéMON table. They resolved the
harness and the sprite paths against the working directory, and the Gold suite
read the generation it wanted out of an environment variable. That is fine from
this repository's root and wrong everywhere else.

The bundles that vendor this mod run each mod's own `tests/*.lua` against the
submodule checkout, staged at a path of their choosing and with no variables
set. All four files failed there, so Gen1WildQOL's CI reported this mod's
passing tests as failures.

Each suite now finds the harness from its own path and names its own
generation, so it answers the same wherever it is run from, under Lua 5.4 and
under LuaJIT alike. The harness moved to `tests/support/` — a bundle globbing
`tests/*.lua` should find the suites and the runner, not a library that was
never meant to be executed on its own.

`lua5.4 tests/run.lua` from the repository root is still the way in, and
`luajit tests/run.lua` works too.

## Notes for mod authors

No API changes, and no changes to `main.lua` or `main_sandbox.lua`. The
`mod.exports` surface is exactly 1.3.0's.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
