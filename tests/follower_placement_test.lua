-- Where the follower LANDS when a map is entered.
--
-- Two things put it in the wrong square, and both of them are here.
--
-- The engine's onMapEntered takes a fourth argument, viaMapLoad, and it is
-- the whole difference between a map ENTRY and a mid-map respawn.  An entry
-- -- a warp, a door, the boot -- parks the follower on the player's own
-- cell, hidden under him, so it walks out of the doorway behind him.  Only
-- a respawn (a bike dismount, a revive, the spawn_pikachu_follower script
-- command) takes the cell behind his facing.  This mod wraps that routine,
-- and the wrapper used to take three arguments and pass three: viaMapLoad
-- was dropped on the way through, every map entry looked like a respawn,
-- and stepping out of a building put the follower on the cell the player
-- had his back to -- back through the door, standing in the building.
--
-- The other is the spawn rule itself.  It asks the MAP whether the cell
-- behind the facing is walkable, and a person standing on that cell does
-- not make it unwalkable, so the follower could arrive squarely on top of
-- an NPC.  The player's cell is the one square always free, so an occupied
-- spawn falls back to it.
--
-- The harness carries the engine's placement rule (tests/support/
-- harness.lua) so what is checked here is what the WRAPPER does to it.
--
-- Run:  lua5.4 tests/follower_placement_test.lua
local HERE = (arg and arg[0] or ""):match("^(.*)[/\\][^/\\]*$") or "."
local h = assert(loadfile(HERE .. "/support/harness.lua"))(HERE .. "/..", 1)
local fails, checks = 0, 0
local function check(name, cond, extra)
  checks = checks + 1
  if cond then print("  ok   " .. name)
  else fails = fails + 1; print("  FAIL " .. name .. (extra and ("  <- " .. tostring(extra)) or "")) end
end

-- a healthy party mon, so the mod's shouldSpawn says yes
h.game.data.pokemon.BULBASAUR = { id = "BULBASAUR", dex = 1 }
h.game.save.party = { { species = "BULBASAUR", hp = 20, level = 16,
                        stats = { hp = 20 } } }

-- an all-walkable map, so the spawn rule's own bounds check never decides
-- anything these cases did not mean it to
local function newMap()
  return { id = "PALLET_TOWN",
           inBounds = function() return true end,
           isWalkableCell = function() return true end }
end

-- the player stepping out of a door faces DOWN, out of the building: the
-- cell "behind the facing" is the one he just came through
local function newWorld(npcs)
  local ow = { npcs = {}, entities = {}, map = newMap(),
               player = { cellX = 5, cellY = 9, facing = "down" } }
  for _, npc in ipairs(npcs or {}) do
    table.insert(ow.npcs, npc)
    table.insert(ow.entities, npc)
  end
  ow.entities[#ow.entities + 1] = ow.player
  h.game.overworld = ow
  return ow
end

local function followerIn(ow)
  for _, npc in ipairs(ow.npcs) do
    if npc.pikachuFollower then return npc end
  end
  return nil
end

local function at(npc, x, y)
  return npc ~= nil and npc.cellX == x and npc.cellY == y
end

print("\n== the fourth argument reaches the engine ==")
do
  local ow = newWorld()
  local before = #h.calls.onMapEntered
  h.PikachuFollower.onMapEntered(h.game, ow, nil, true)
  local call = h.calls.onMapEntered[#h.calls.onMapEntered]
  check("the wrapper passed the call through", #h.calls.onMapEntered == before + 1)
  check("viaMapLoad arrives as true, not nil", call.viaMapLoad == true,
        tostring(call.viaMapLoad))
  check("and four arguments arrive, not three", call.n == 4, call.n)
end

print("\n== walking out of a building ==")
do
  local ow = newWorld()
  h.PikachuFollower.onMapEntered(h.game, ow, nil, true)
  local follower = followerIn(ow)
  check("the follower spawned", follower ~= nil)
  check("it is under the player, not back through the door",
        at(follower, 5, 9),
        follower and (follower.cellX .. "," .. follower.cellY))
  check("its pixel position moved with it",
        follower and follower.px == 80 and follower.py == 144,
        follower and (follower.px .. "," .. follower.py))
end

print("\n== a mid-map respawn still trails behind the facing ==")
do
  local ow = newWorld()
  h.PikachuFollower.onMapEntered(h.game, ow, nil, false)
  local follower = followerIn(ow)
  check("the follower spawned", follower ~= nil)
  check("facing down, it stands one cell north", at(follower, 5, 8),
        follower and (follower.cellX .. "," .. follower.cellY))
end

print("\n== it does not stand on somebody ==")
do
  -- the respawn cell, occupied
  local shopkeeper = { cellX = 5, cellY = 8, px = 80, py = 128 }
  local ow = newWorld({ shopkeeper })
  h.PikachuFollower.onMapEntered(h.game, ow, nil, false)
  local follower = followerIn(ow)
  check("the follower spawned", follower ~= nil)
  check("it gave the occupied cell up", not at(follower, 5, 8),
        follower and (follower.cellX .. "," .. follower.cellY))
  check("and took the player's, the one square always free",
        at(follower, 5, 9),
        follower and (follower.cellX .. "," .. follower.cellY))
  check("the NPC was not moved to make room",
        shopkeeper.cellX == 5 and shopkeeper.cellY == 8)
end

print("\n== an unoccupied respawn is left alone ==")
do
  local passerby = { cellX = 2, cellY = 2 }
  local ow = newWorld({ passerby })
  h.PikachuFollower.onMapEntered(h.game, ow, nil, false)
  check("nobody in the way, nothing moved", at(followerIn(ow), 5, 8))
end

print(("\n%d/%d checks passed"):format(checks - fails, checks))
if fails > 0 then os.exit(1) end
