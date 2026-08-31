# Changelog

## 1.6.1

- **A black square outline no longer forms around the character on the way into
  a battle.** A full-colour overworld sprite marks a rectangle to be re-blitted
  raw, out of the colorize pass. `Renderer.scissorClamped` rounds every zone
  *outward* on purpose — so two SGB zones share an edge rather than letting the
  letterbox show through between them — and this rectangle was rounded outward
  here as well, so it ended up a pixel or more proud of the sprite on every
  side. That margin is background, and background left out of the colorize pass
  is invisible until something changes the ground: a battle wipes the screen,
  the ground goes, the ring stays, and it reads as an outline around the
  character.

  The rectangle now rounds inward and insets one further, so it is a subset of
  the sprite and the widest it can round back out to is the sprite's own edge.
  The pixel given back is the sprite's outermost ring, which is its black
  outline — the one colour the pass has nothing to do to.

  `ADVANCED` only, because `honorsTrueColor()` is `PaletteFX.mode == "redpp"`
  and nothing else splices these rectangles at all; and `LIGHT` only, because
  the dark path draws straight onto the world canvas and never marks one.

`tests/truecolor_rect_test.lua` holds the invariant — the rectangle is inside
the sprite, at whole and fractional anchors and at every scale — and a sprite
too small to inset asks for nothing rather than for an inside-out rectangle.

## 1.6.0

Gen1WildQOL carried this as an overlay while it was ahead of a release here; it
shipped in the bundle's 1.27.0. Same code, in the mod that owns it.

- **A map POKéMON whose cell is off the visible area is culled.** The mark-only
  branch does not draw into the world canvas: it queues a post-zone redraw,
  which the renderer replays in *screen* space. So a sprite outside the game
  screen was painted into the black beside it, floating next to the picture
  instead of being clipped with everything else.

## 1.5.1 - 2026-08-29

### Fixed
- **The follower no longer walks out of a door standing inside the building.**
  The engine's `onMapEntered` takes a fourth argument, and it decides
  everything about where the follower lands: a map ENTRY -- a warp, a door,
  the boot -- parks it on the player's own cell so it comes out of the doorway
  behind him, and only a mid-map respawn takes the cell behind his facing.
  This mod's wrapper took three arguments and passed three, so that argument
  was dropped on the way through and every map entry was treated as a respawn.
  Stepping outside, the player faces down and the cell behind his facing is
  the one he just came through -- so the follower stood in the building.

- **It no longer stands on top of an NPC.** The spawn rule asks the map
  whether the cell behind the facing is walkable, and somebody standing there
  does not make it unwalkable, so the follower could arrive squarely on
  another sprite. When that cell is taken it now falls back to the player's
  own cell -- the one square that is always free, and where a map entry puts
  it anyway.

  `tests/follower_placement_test.lua` carries the engine's placement rule and
  holds both.

## 1.5.0 - 2026-08-29

### Changed
- **`POKEDEX SIZES` ships OFF.** Every follower is now drawn at the size its
  art was drawn at. All 251 sheets are 16x16, so at 1.0 each sprite is exactly
  what its artist made.

  Proportional sizing is still one row away, and still worth having — a
  Pokédex-scaled Onix is a good thing to see. But it is bought by making
  everything else relative to it, and that is a preference rather than the
  shipping state. 1.4.0 stopped it from mangling small species; this stops it
  from being the default anyone has to discover.

  Nothing is ever drawn below 1.0 either way.

## 1.4.0 - 2026-08-29

### Fixed
- **Small POKéMON are not squashed into a blob any more.** The follower sheets
  are 16x16, and that is the whole detail budget. `MIN_FOLLOWER_SCALE` was
  `0.6875`, so every small species clamped to it and a 16px sprite was resampled
  down to **11px** — five rows and five columns thrown away, taking 67 of
  Bulbasaur's 138 opaque pixels with them.

  What survived did not read as a small Bulbasaur, it read as a flat teal blob:
  the legs merged into two black bars, the bulb lost its outline, and the
  shading collapsed until the art looked like two colours rather than the three
  it has. Every small species hit that floor, which is why the whole set looked
  wrong rather than one sprite.

  The floor is `1.0` now. Nothing is ever drawn below its native size. Big
  species still grow — Onix 31px, Snorlax 17px — because scaling 16px **up** by
  a whole number keeps every pixel, while scaling down has no detail to spend.
  `FOLLOWER SIZE` cannot push below native either.

  A test pins it: with the old floor it fails on `DIGLETT = 0.6875`.

## 1.3.3 - 2026-08-28

### Changed
- **A dead option read is gone.** The draw path asked an option called
  `color_mode` whether the answer was `"gbc"`, which would have sent the
  full-colour follower sheets through the engine's four-shade remap instead of
  past it.

  Nothing has ever defined that key. Not this mod, which never listed it in
  `options:define`, and not the engine, which has no such row anywhere in it.
  The mod option API answers `nil` for a key it has no schema for, so the
  comparison was false on every boot this mod has ever had and the branch was
  dead the day it was written.

  It is spelled as the constant it always evaluated to now, so it does not read
  as a setting that went missing. **No behaviour changes** — this is the same
  answer the function was already returning every time.

## 1.3.2 - 2026-08-27

### Fixed
- **Map POKéMON no longer flip back and forth on the spot.** A Pokémon standing
  on a map would mirror itself left-to-right and back as you walked around it,
  looking like it was trying to play a walk animation without going anywhere.

  This mod's draw path mirrors an up- or down-facing sprite whenever the engine
  hands it `stepFlip`. The engine's own rule is narrower: it mirrors only on
  the *stepping* half of a stride. `stepFlip` is not a stride — an NPC toggles
  it when a step **ends** and then stands there holding it — so a wandering
  Pokémon that had taken an odd number of steps stood permanently mirrored
  until its next step turned it back, and mirrored on both halves of every
  stride it did take.

  The pose is now the engine's, rule for rule: the walk frames gated on the
  sheet being a walker, the up/down mirror gated on the stepping half, and
  right-facing the mirror of left at any phase. Six tests pin it, and they fail
  against the old rule.

  The follower had the same rule and the same latent flip, hidden by walking in
  step with the player; it is fixed too.

## 1.3.1 - 2026-08-27

### Fixed
- **The test suites run from anywhere, and under LuaJIT.** They resolved the
  harness and the sprite paths against the working directory and read the
  generation out of an environment variable, which is fine from this
  repository's root and wrong everywhere else. The bundles that vendor this mod
  run each mod's `tests/*.lua` themselves, staged at a path of their choosing
  and with no variables set, so all four files failed there and reported this
  mod's passing tests as failures in Gen1WildQOL's CI.

  Each suite now finds the harness from its own path and names its own
  generation, so it gives the same answer wherever it is run from and under
  either interpreter. The harness moved to `tests/support/` so that a bundle
  globbing `tests/*.lua` picks up the two suites and the runner rather than a
  library that was never meant to be run on its own.

  No change to the mod. `lua5.4 tests/run.lua` is still the way in, and the
  1.3.0 behaviour is untouched.

## 1.3.0 - 2026-08-27

### Added
- **The Pokémon standing on the maps wear the follower's sheets too.** Gen 1
  draws every Pokémon that is part of a map from one of five shared sheets:
  a "monster", a "bird", a "fairy", a "seel" and the one Snorlax. One monster
  is Mewtwo, a Meowth, a Machop and a Kangaskhan at once; one fairy is the
  Pokémon Fan Club's Pikachu as readily as it is a Clefairy. So a save whose
  follower came from this mod's own 251 sheets still walked past Pokémon in
  the cart's generic art, and the two never matched.

  Fifty map objects across Red, Blue and Yellow now draw from the same
  sheet the mod would give that species as a follower, at the same
  Pokédex-proportional size and in the same full colour — the Fan Club's
  Pikachu and Seel, both sleeping Snorlax, Mewtwo, Articuno, Zapdos, Moltres,
  Melanie's three, every Pokémon Center's Chansey, the pair in Mr. Fuji's
  house, Fuchsia's Lapras and the rest. Each one is picked by the map object's
  own name, so a Pidgey stays a Pidgey and a Pidgeot a Pidgeot even though the
  cart draws both from the one bird.

  Three Pokémon-shaped objects are deliberately left as they are. The monster,
  bird and fairy in the Copycat's room are dolls, and her joke is that they
  are. The Power Plant's Voltorb and Electrode are not touched either: they
  wear the item-ball sprite because they are pretending to be item balls,
  which is the trap.

  One of the fifty is a decision rather than a reading. Bill only ever says he
  "got combined with a #MON" and the game never names it, so there is no data
  to settle what he should be drawn as; he is Kabuto here — the shell he spends
  his anime appearance stuck inside — and that is a one-word edit in the table
  for anyone who would rather he were something else.

  On Gold the same thing happens one level up. Its overworld Pokémon already
  name their species, but they borrow that species' shared party-menu icon for
  art, so they get the follower sheet instead — and the two-frame bob is moved
  onto the sheet's walking frame, since on a follower sheet the frame the
  bounce would otherwise use is the mon facing away from you.

  All of it is one switch, `MAP POKEMON`, on by default; turning it off puts
  the cart's sprites back without a map reload.

## 1.2.1 - 2026-08-26

### Fixed
- **Followers darken with the rest of a dark cave.** Rock Tunnel and the other
  unlit floors black out every sprite on screen — Gen 1 arms `FadePal2`, whose
  `rOBP0` write lands every object colour on shade 3, and Gen 2 loads the
  DARKNESS palette set — so the player, NPCs and item balls are silhouettes
  until `FLASH`. Full-colour follower art reached the screen past both of
  them, either replayed unshaded on top of the colorized pass or exempted
  from it by a true-colour rect, and the follower kept walking around in
  daylight colours beside a blacked-out player.

  In an unlit frame the follower is now painted in the same shade the engine
  leaves the player: shade 3 of the palette that frame colours objects with,
  at whatever Pokédex size the follower already had. A battle drawn over a
  dark map still comes out lit, exactly as the engine draws that frame, and
  `FLASH` brings the follower's own colours back with everything else.

## 1.2.0 - 2026-08-25

### Added
- **Turning the follower off from the party menu.** `FOLLOWER` — the label the
  party submenu already shows on the Pokémon walking behind you — is now a
  toggle rather than a re-selection of the Pokémon that is already selected.
  Choosing it ends the following and leaves you with no follower at all; every
  party member then reads `FOLLOW?` again, and picking one starts a follower
  back up.

  The switch is saved next to the follower selection, so it survives map
  transitions, save reloads and hot reloads, and a party reorder or a new lead
  Pokémon no longer brings a follower back on its own. Red, Blue, Yellow and
  Gold all behave the same way; on Yellow, where the game's own spawn gate
  still passes with a healthy Pikachu in the party, the follower is also
  removed from the world rather than merely not spawned.

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
