# Changelog

## 1.1.0 - 2026-08-25

### Removed
- **Yellow's starter is Pikachu again.** The mod no longer rewrites Yellow's
  opening: it had renamed the `PIKACHU` string to `CHARMANDER`, replaced three
  of Oak's lab lines, and wrapped `encounter.species` to turn the level-5
  Pikachu roll into a Charmander. That ran on every Yellow save with no option
  to switch it off, which made installing a follower mod silently change the
  starter you were given. Deciding which Pokemon walks behind you is this
  mod's job; deciding which one Oak hands you is not.

  Red, Blue and Gold are unaffected — the block was already Yellow-only. On
  Yellow, the native spawn-gate shim and the vanilla-talk path for the starter
  Pikachu are unchanged, so the follower itself behaves exactly as before.

## 1.0.0 - 2026-08-23

First release of **Gen1Follower**, a standalone all-species overworld follower
mod for Gen1Recomp. It is an independent build of the PokéPC Followers
lineage — released under its own identity rather than as a fork — and ships
the full feature set as its 1.0.0 baseline.

### Added
- All 251 Generation I and Generation II overworld followers, using native
  GSC-style follower sheets rather than HGSS downscales.
- Automatic Party Slot 1 follower with live lead switching, plus an explicit
  `FOLLOW?` action in the party menu and a saved per-save selection.
- Pokédex-proportional follower sizing with a capped scale, a `POKEDEX SIZES`
  toggle and a 75%–125% `FOLLOWER SIZE` adjustment.
- Red, Blue and Gold follower spawning without Yellow-only story flags, and
  native Gen 2 support on Gold (251-species Pokédex, Gen 2 sprite registry,
  split icon sheet).
- Crystal 251 integration: Johto species are read from Crystal 251's
  registered Pokédex data at runtime on Gen 1.
- Voxel compatibility for the Dramatic Shape family — Dramatic Shape,
  Dramaless Shape and Battle Art Voxel Fork — including Pokédex-derived sizes
  on billboard and shadow meshes.
- Unique Menu Icons compatibility: it owns the party-menu icon column when
  both mods are enabled.
- Gen1Recomp 0.1.86+ sandbox bootstrap with scoped asset paths, no filesystem
  permission and no `debug` dependency.

### Changed from the PokéPC Followers build this was branded from
- Mod id, display name, author, repository and release archive are now
  `Gen1Follower` / `wild1walker/Gen1Follower`. The launcher treats this as a
  separate mod from `PokePCFollowers`; enable one or the other, not both.
- `mod.exports.providerRepository` now reports `wild1walker/Gen1Follower`.
  The lineage is published separately as `mod.exports.upstreamRepository` so
  consumers written against the PokéPC provider contract can still recognise
  this build.
- The release workflow validates the manifest's version shape and its
  changelog entry instead of a pinned literal version, so a version bump is a
  single-file edit.

### Preserved
- The `__pokepc*` / `pokepcFollower*` / `ICON_POKEPC_` markers this mod writes
  onto engine and third-party tables keep their historical names. They are the
  handshake a PokéPC-lineage follower mod uses to detect that another one has
  already installed its wrappers; renaming them would let two lineage mods
  stack wrappers on the same engine functions.
- Every behavioural fix from the lineage, including the fainted-lead spawn fix,
  the fainted-follower render fix and the shortened `FOLLOWER` / `FOLLOW?`
  party submenu labels.
