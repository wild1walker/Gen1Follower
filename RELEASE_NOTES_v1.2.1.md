# Gen1Follower 1.2.1

Your follower goes dark with the rest of the cave. Rock Tunnel and the other
unlit floors used to leave it walking around in full daylight colours beside a
blacked-out player. Works on **Pokémon Red, Blue, Yellow and Gold
(Gen1Recomp)**.

**Requires Gen1Recomp 0.1.86 or newer.**

## Install

Download `Gen1Follower-1.2.1.zip` and import it through `MODS > Import mod .zip`,
or unpack it into `mods/`.

## The dark cave fix

An unlit floor blacks out every sprite on screen. Gen 1 arms `FadePal2` for the
frame — the same write also sends `rOBP0`, which lands every object colour on
shade 3 — and Gen 2 loads the DARKNESS palette set, so the player, NPCs and item
balls are silhouettes until `FLASH`.

The follower's full-colour art reached the screen past both of them. At Pokédex
size 1 its draw was replayed unshaded on top of the colorized pass; at any other
size it was drawn under a true-colour rect that exempted it from that pass.
Either way it kept its daylight colours.

In an unlit frame the follower is now painted in the same shade the engine
leaves the player: shade 3 of whatever palette that frame colours objects with —
so it matches in every COLORS mode, from SGB through ADVANCED to the mono and
inverted looks, and on Gold's own dark caves. `FLASH` brings its colours back
with everything else.

Nothing else about the follower changes: Pokédex sizing, flipping, walk frames
and the lit overworld all render exactly as they did in 1.2.0. A battle drawn
over a dark map still comes out lit, matching how the engine draws that frame.

## Known gap

In Dramatic Shape-family voxel/tilt mode the follower is drawn as a billboard by
the voxel provider rather than through this mod's 2D draw hook, so it is still
lit inside a dark cave there.

## Notes for mod authors

No API changes. `mod.exports` — `resolveFollowerSprite`, `providerRepository`,
`upstreamRepository`, `activeMon`, `shouldSpawn`, `followingDisabled`, `stop`
and the rest — is unchanged from 1.2.0.

Sprite credits and third-party attribution are unchanged; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
