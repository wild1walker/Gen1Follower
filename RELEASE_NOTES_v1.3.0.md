# Gen1Follower 1.3.0

The Pokémon standing on the maps now wear the same sheets your follower does.
Works on **Pokémon Red, Blue, Yellow and Gold (Gen1Recomp)**.

**Requires Gen1Recomp 0.1.86 or newer.**

## Install

Download `Gen1Follower-1.3.0.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`.

## Map POKéMON

Gen 1 draws every Pokémon that is part of a map from one of five shared sheets:
a "monster", a "bird", a "fairy", a "seel" and the one Snorlax. A single monster
is Mewtwo, a Meowth, a Machop and a Kangaskhan at once; one fairy is the Pokémon
Fan Club's Pikachu as readily as it is a Clefairy. So a save whose follower came
from this mod's own 251 sheets still walked past Pokémon in the cart's generic
art, and the two never matched.

Fifty map objects across Red, Blue and Yellow now draw from the very sheet this
mod would give that species as a follower, at the same Pokédex-proportional size
and in the same full colour:

- the Pokémon Fan Club's Pikachu and Seel
- both sleeping Snorlax, on Route 12 and Route 16
- Mewtwo in Cerulean Cave, and Articuno, Zapdos and Moltres
- Bill's fused form
- Melanie's Bulbasaur, Oddish and Sandshrew, and the beach house Pikachu
- every Pokémon Center's Chansey
- Mr. Fuji's Psyduck and Nidorino, Fuchsia's Lapras and Kangaskhan, Vermilion's
  Machop, the S.S. Anne's Machoke and Wigglytuff, Celadon's Meowth and Clefairy,
  Lavender's Cubone, the four Pidgey-family birds and the Viridian Spearow

Each is chosen by the map object's own name rather than by its sprite id — the
id is the very thing that lost the species — so a Pidgey stays a Pidgey and a
Pidgeot a Pidgeot even though the cart draws both from the one bird. A second
check that the object is already wearing one of the sheets the cart draws a
Pokémon from keeps a name collision on a person out.

All of it is one switch, `MAP POKEMON`, on by default. Turning it off puts the
cart's sprites back without a map reload.

## What is deliberately left alone

The monster, bird and fairy in the Copycat's room keep the cart's art, because
they are dolls and her joke is that they are — "This is a rare #MON! Huh? It's
only a doll!" Giving them real Pokémon art tells the punchline first.

The Power Plant's Voltorb and Electrode are untouched for the same kind of
reason: they wear the item-ball sprite because they are pretending to be item
balls, which is the trap.

## One judgement call

Bill's fused form is the one object no game data can settle. He only ever says
he "got combined with a #MON" and the cart never names it. He is drawn as a
Kabuto here — the shell he spends his anime appearance stuck inside — which is a
decision rather than a reading, and it is one word in `OVERWORLD_MON_SPECIES`
for anyone who would rather he were something else.

## On Gold

Gold needs no object table. Its overworld Pokémon already name their species and
merely borrow that species' shared party-menu icon for art, so the sprite record
itself is repointed at this mod's sheet. The two-frame bob moves onto the
sheet's walking frame, because the frame the bounce would otherwise raise is the
mon facing away from you.

## Checks

`lua5.4 tests/run.lua` runs 41 assertions over a stubbed engine: which sheet each
map object ends up with, the exclusions above, the draw path, and the follower's
own path, unchanged. It says nothing about how any of it looks on screen.

## Notes for mod authors

No API changes. `mod.exports` — `resolveFollowerSprite`, `providerRepository`,
`upstreamRepository`, `activeMon`, `shouldSpawn`, `followingDisabled`, `stop`
and the rest — is unchanged from 1.2.1.

New sprite records are registered under `SPRITE_GEN1FOLLOWER_MON_<dex>`, one per
species the maps use. They carry `pokepcFollowerSpecies` and
`pokepcFollowerVisualScale`, so the voxel billboard hook sizes them exactly as
it sizes the follower.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
