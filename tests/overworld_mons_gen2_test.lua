local h = dofile("tests/harness.lua")
local fails, checks = 0, 0
local function check(name, cond, extra)
  checks = checks + 1
  if cond then print("  ok   " .. name)
  else fails = fails + 1; print("  FAIL " .. name .. (extra and ("  <- " .. tostring(extra)) or "")) end
end

-- Gold's own mon records: a species plus the SHARED party-icon sheet
h.sprites.SPRITE_POKEMON_1 = { id = "SPRITE_POKEMON_1", species = "SUDOWOODO",
  spriteType = "POKEMON_SPRITE", frames = 2, walker = false,
  image = "assets/generated/icons/gen2/tree.png", icon = "ICON_TREE" }
h.sprites.SPRITE_POKEMON_2 = { id = "SPRITE_POKEMON_2", species = "GYARADOS",
  spriteType = "POKEMON_SPRITE", frames = 2, walker = false,
  image = "assets/generated/icons/gen2/serpent.png", icon = "ICON_SERPENT" }
h.sprites.SPRITE_BEAUTY = { id = "SPRITE_BEAUTY", spriteType = "WALKING_SPRITE",
  frames = 6, walker = true, image = "assets/generated/sprites/beauty.png" }

-- Gold knows all 251 natively; the mod's own table stops at 151, so the
-- Johto half of a dex lookup comes from game.data.pokemon.
h.game.data.pokemon.SUDOWOODO = { id = "SUDOWOODO", dex = 185 }

local ow = { npcs = {}, entities = {}, map = { id = "ROUTE_36" } }
h.game.overworld = ow

print("\n== Gold: map POKeMON records ==")
h.PikachuFollower.onMapEntered(h.game, ow)
local sudo = h.sprites.SPRITE_POKEMON_1
check("Sudowoodo leaves the shared party icon",
  sudo.image == "./assets/sprites/follower_185.png", sudo.image)
check("...as a 6-frame sheet", sudo.frames == 6, sudo.frames)
check("...tagged with its species", sudo.pokepcFollowerSpecies == "SUDOWOODO")
check("Gyarados likewise",
  h.sprites.SPRITE_POKEMON_2.image
    == "./assets/sprites/follower_130.png",
  h.sprites.SPRITE_POKEMON_2.image)
check("a human sprite record is untouched",
  h.sprites.SPRITE_BEAUTY.image == "assets/generated/sprites/beauty.png"
    and h.sprites.SPRITE_BEAUTY.frames == 6)

print("\n== Gold: the bounce ==")
local mon = setmetatable({ bouncing = true, raised = false,
  sprite = { def = sudo } }, h.Gen2NPC)
check("the resting half of the bounce is the stand frame", mon:bounceFrame() == 0)
mon.raised = true
check("the raised half moves to the down-facing STEP frame (3), not 'stand up'",
  mon:bounceFrame() == 3, mon:bounceFrame())
local person = setmetatable({ bouncing = true, raised = true,
  sprite = { def = h.sprites.SPRITE_BEAUTY } }, h.Gen2NPC)
check("a sprite this mod did not repoint keeps the engine's frame 1",
  person:bounceFrame() == 1, person:bounceFrame())
local still = setmetatable({ bouncing = false, sprite = { def = sudo } }, h.Gen2NPC)
check("a non-bouncing object still gets nil", still:bounceFrame() == nil)

print("\n== Gold: switching the option off puts the icons back ==")
h.options.overworld_mon_sprites = false
h.PikachuFollower.onMapEntered(h.game, ow)
check("Sudowoodo is back on its party icon",
  sudo.image == "assets/generated/icons/gen2/tree.png", sudo.image)
check("...at two frames again", sudo.frames == 2, sudo.frames)
check("...and untagged", sudo.pokepcFollowerSpecies == nil)

print(string.format("\n%d/%d checks passed", checks - fails, checks))
os.exit(fails == 0 and 0 or 1)
