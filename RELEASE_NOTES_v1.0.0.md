# Gen1Follower 1.0.0

First release of Gen1Follower — an all-species overworld follower mod for
**Pokémon Red, Blue, Yellow and Gold (Gen1Recomp)**, released under its own
identity rather than as a fork of the PokéPC Followers build it grew out of.

**Requires Gen1Recomp 0.1.86 or newer.**

## Install

Download `Gen1Follower-1.0.0.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`.

On Red, Blue or Yellow, also install **Crystal 251** to use Pokémon `#152`–`#251`.
On Gold, all 251 species work from the game's own Pokédex data.

If you previously ran `PokePCFollowers`, disable it first. The launcher sees the
two as separate mods and running both at once stacks two copies of the same
follower hooks.

## What's in it

- All 251 Gen 1 and Gen 2 overworld followers, native GSC-style sheets.
- Party Slot 1 follower by default, plus the `FOLLOW?` party-menu action and a
  saved selection per file.
- Pokédex-proportional sizes with a `POKEDEX SIZES` toggle and a 75%–125%
  `FOLLOWER SIZE` slider.
- Red, Blue and Gold spawning without Yellow-only story flags; native Gen 2
  support on Gold.
- Crystal 251 species detection, Dramatic Shape-family voxel compatibility and
  Unique Menu Icons compatibility.
- Correct behaviour with a fainted lead: the follower still spawns, and a
  fainted Pokémon is never drawn walking behind you.

## Notes for mod authors

`mod.exports.providerRepository` is `wild1walker/Gen1Follower`. If your mod
matched on the PokéPC provider string, read `mod.exports.upstreamRepository`
as well — it still reports `mfrtechconsult/PokePCFollowers`. The follower
sprite contract (`mod.exports.resolveFollowerSprite`) is unchanged.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
