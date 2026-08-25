# Gen1Follower 1.2.0

`FOLLOWER` in the party menu is now a toggle: selecting it on the Pokémon
walking behind you ends the following, so you can travel with nobody at your
back. Works on **Pokémon Red, Blue, Yellow and Gold (Gen1Recomp)**.

**Requires Gen1Recomp 0.1.86 or newer.**

## Install

Download `Gen1Follower-1.2.0.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`.

## Walking with no follower

`FOLLOW?` and `FOLLOWER` are the same party-submenu entry in two states, and it
is now a switch you can turn both ways:

1. Press `START` -> select `POKéMON`, then choose a Pokémon.
2. `FOLLOW?` on any healthy party member makes it your follower.
3. `FOLLOWER` — shown only on the Pokémon already following you — ends the
   following. Nobody walks behind you, and every party member reads `FOLLOW?`
   again until you pick one.

Before this release, selecting `FOLLOWER` only re-selected the Pokémon that was
already selected, and the mod always resolved *some* follower, falling back to
the party lead. There was no way to walk alone.

Off stays off. The choice is saved beside the follower selection, so it survives
map transitions, save reloads and mod hot reloads — and reordering your party or
receiving a new lead Pokémon no longer quietly brings a follower back. Only
choosing `FOLLOW?` yourself does.

Red, Blue, Yellow and Gold all behave the same way. On Yellow, where the game's
own spawn gate still passes while a healthy Pikachu is in the party, the follower
is also removed from the world rather than merely not spawned.

## Notes for mod authors

`mod.exports.activeMon` reports `nil` while following is switched off, matching
`mod.exports.shouldSpawn`. Two exports are added: `mod.exports.followingDisabled()`
reads the switch, and `mod.exports.stop(game)` turns following off quietly.

The follower sprite contract (`mod.exports.resolveFollowerSprite`),
`providerRepository` and `upstreamRepository` are unchanged.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
