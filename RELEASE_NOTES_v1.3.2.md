# Gen1Follower 1.3.2

Fixes map POKéMON flipping back and forth on the spot. **Requires Gen1Recomp
0.1.86 or newer.**

## Install

Download `Gen1Follower-1.3.2.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`.

## The flipping

A Pokémon standing on a map would mirror itself left-to-right and back as you
walked around it — the Fan Club's Pikachu, a Pidgey, a wandering Chansey —
looking like it was trying to play a walk animation without going anywhere.

This mod draws those sprites itself, because it has to size them from the
Pokédex, and its copy of the engine's pose rules mirrored an up- or
down-facing sprite whenever it was handed `stepFlip`. The engine's rule is
narrower: it mirrors only on the *stepping* half of a stride.

`stepFlip` is not a stride. An NPC toggles it when a step **ends** and then
stands there holding it, so a wandering Pokémon that had taken an odd number of
steps stood permanently mirrored until its next step turned it back — and
mirrored on both halves of every stride it did take, twice as often as the
engine would.

The pose is now the engine's, rule for rule: walk frames gated on the sheet
being a walker, the up/down mirror gated on the stepping half, and
right-facing the mirror of left at any phase.

The follower carried the same rule and the same latent flip — hidden, because
it walks in step with the player and a mirror there reads as the animation
doing its job. It is fixed with everything else.

## Notes for mod authors

No API changes. `mod.exports` is exactly 1.3.1's, and nothing about which
species a map object is drawn as has moved.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
