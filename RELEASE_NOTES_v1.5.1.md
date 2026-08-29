# Gen1Follower 1.5.1

Two squares the follower got wrong.

## It walked out of doors standing inside the building

The engine's `onMapEntered` takes a fourth argument, and it decides everything
about where the follower lands. A map **entry** — a warp, a door, the boot —
parks it on the player's own cell, hidden under him, so it comes out of the
doorway behind him. Only a mid-map **respawn** (a bike dismount, a revive, the
`spawn_pikachu_follower` script command) takes the cell behind his facing.

This mod's wrapper around that routine took three arguments and passed three,
so the fourth was dropped on the way through and every map entry was treated
as a respawn. Stepping outside, the player faces down — and the cell behind
his facing is the one he just came through. So the follower stood in the
building.

## It stood on top of people

The spawn rule asks the **map** whether the cell behind the facing is
walkable, and somebody standing on that cell does not make it unwalkable. So
the follower could arrive squarely on another sprite, with no way to tell
which of the two the A button would reach.

When that cell is taken, the follower now falls back to the player's own cell
— the one square that is always free, and where a map entry puts it anyway.
The NPC is not moved.

## Tests

`tests/follower_placement_test.lua` carries the engine's placement rule and
holds both. It fails on the old wrapper, with the follower one cell north of
the player: inside the building.
