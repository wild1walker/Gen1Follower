-- Finds the harness from THIS file's path rather than the working directory,
-- and names its own generation rather than reading one out of the environment:
-- the bundle repositories run each vendored mod's suites directly, from a
-- directory of their choosing and with no variables set.
local HERE = (arg and arg[0] or ""):match("^(.*)[/\\][^/\\]*$") or "."
local h = assert(loadfile(HERE .. "/support/harness.lua"))(HERE .. "/..", 1)
local fails, checks = 0, 0
local function check(name, cond, extra)
  checks = checks + 1
  if cond then print("  ok   " .. name)
  else fails = fails + 1; print("  FAIL " .. name .. (extra and ("  <- " .. tostring(extra)) or "")) end
end

local function build(mapId, obj) return h.NPC.new(h.game.data, mapId, obj) end
local function sheet(npc) return npc.sprite.def.image end
local function isFollowerArt(npc)
  return (sheet(npc) or ""):find("/assets/sprites/follower_", 1, true) ~= nil
end

print("\n== registered records ==")
local n = 0
for id in pairs(h.sprites) do if id:find("^SPRITE_GEN1FOLLOWER_MON_") then n = n + 1 end end
check("one record per distinct species (33)", n == 33, n)
check("Pikachu record points at follower_025.png",
  (h.sprites.SPRITE_GEN1FOLLOWER_MON_025 or {}).image
    == (HERE .. "/../assets/sprites/follower_025.png"),
  (h.sprites.SPRITE_GEN1FOLLOWER_MON_025 or {}).image)
check("records are 6-frame walkers",
  (h.sprites.SPRITE_GEN1FOLLOWER_MON_143 or {}).frames == 6
    and (h.sprites.SPRITE_GEN1FOLLOWER_MON_143 or {}).walker == true)

print("\n== the objects the user named ==")
local pika = build("POKEMON_FAN_CLUB",
  { index = 3, x = 6, y = 4, sprite = "SPRITE_FAIRY", movement = "STAY",
    range = "LEFT", name = "POKEMONFANCLUB_PIKACHU" })
check("Fan Club Pikachu leaves the fairy sheet", isFollowerArt(pika), sheet(pika))
check("...and is Pikachu", sheet(pika):find("follower_025") ~= nil, sheet(pika))

local snorlax = build("ROUTE_12",
  { index = 1, x = 10, y = 62, sprite = "SPRITE_SNORLAX", movement = "STAY",
    range = "DOWN", name = "ROUTE12_SNORLAX" })
check("Route 12 Snorlax is follower_143", sheet(snorlax):find("follower_143") ~= nil, sheet(snorlax))

-- The one row no game data settles: Bill's fused form is Kabuto by decision.
local bill = build("BILLS_HOUSE",
  { index = 1, x = 6, y = 5, sprite = "SPRITE_MONSTER", movement = "STAY",
    range = "NONE", name = "BILLSHOUSE_BILL_POKEMON" })
check("Bill's fused form is Kabuto", sheet(bill):find("follower_140") ~= nil, sheet(bill))

print("\n== the ones that must NOT change ==")
local doll = build("COPYCATS_HOUSE_2F",
  { index = 4, x = 5, y = 1, sprite = "SPRITE_MONSTER", movement = "STAY",
    range = "DOWN", name = "COPYCATSHOUSE2F_MONSTER" })
check("the Copycat's monster DOLL is untouched", not isFollowerArt(doll), sheet(doll))

local voltorb = build("POWER_PLANT",
  { index = 2, x = 9, y = 20, sprite = "SPRITE_POKE_BALL", movement = "STAY",
    range = "NONE", name = "POWERPLANT_VOLTORB1", pokemon = "VOLTORB", level = 40 })
check("the Power Plant's disguised Voltorb is untouched", not isFollowerArt(voltorb), sheet(voltorb))

local human = build("POKEMON_FAN_CLUB",
  { index = 5, x = 3, y = 1, sprite = "SPRITE_GENTLEMAN", movement = "STAY",
    range = "DOWN", name = "POKEMONFANCLUB_CHAIRMAN" })
check("an unlisted human NPC is untouched", not isFollowerArt(human), sheet(human))

-- a name collision on a human: the sheet check is the second lock
local impostor = build("MODDED_MAP",
  { index = 1, x = 1, y = 1, sprite = "SPRITE_GENTLEMAN", movement = "STAY",
    range = "DOWN", name = "ROUTE12_SNORLAX" })
check("a listed NAME on a human sheet is refused", not isFollowerArt(impostor), sheet(impostor))

print("\n== the four legendaries and the birds ==")
for name, want in pairs({ POWERPLANT_ZAPDOS = "follower_145",
    SEAFOAMISLANDSB4F_ARTICUNO = "follower_144",
    VICTORYROAD2F_MOLTRES = "follower_146",
    CERULEANCAVEB1F_MEWTWO = "follower_150",
    VIRIDIANNICKNAMEHOUSE_SPEAROW = "follower_021" }) do
  local npc = build("M", { index = 1, x = 1, y = 1,
    sprite = name == "CERULEANCAVEB1F_MEWTWO" and "SPRITE_MONSTER" or "SPRITE_BIRD",
    movement = "STAY", range = "DOWN", name = name })
  check(name .. " -> " .. want, sheet(npc):find(want) ~= nil, sheet(npc))
end

print("\n== Yellow's own per-species sheets ==")
local chansey = build("VIRIDIAN_POKECENTER",
  { index = 4, x = 4, y = 1, sprite = "SPRITE_CHANSEY", movement = "STAY",
    range = "DOWN", name = "VIRIDIANPOKECENTER_CHANSEY" })
check("a Yellow Chansey moves from the cart's sheet to this mod's",
  sheet(chansey):find("follower_113") ~= nil, sheet(chansey))
local beachPika = build("SUMMER_BEACH_HOUSE",
  { index = 1, x = 5, y = 3, sprite = "SPRITE_PIKACHU", movement = "WALK",
    range = 1, name = "SUMMERBEACHHOUSE_PIKACHU" })
check("the beach house Pikachu likewise",
  sheet(beachPika):find("follower_025") ~= nil, sheet(beachPika))

print("\n== the draw path ==")
local before = #h.drawn
pika.sprite:draw(96, 64, 0, 0, "down", 0, false)
check("a map POKeMON goes through the mod's own draw", #h.drawn == before + 1
  and h.drawn[#h.drawn].vanilla == nil, h.drawn[#h.drawn].vanilla)
check("...painting the follower sheet",
  (h.drawn[#h.drawn].image or {}).path
    == (HERE .. "/../assets/sprites/follower_025.png"),
  (h.drawn[#h.drawn].image or {}).path)
before = #h.drawn
human.sprite:draw(96, 64, 0, 0, "down", 0, false)
check("a human NPC still goes through the engine's draw",
  h.drawn[#h.drawn].vanilla == true)

print("\n== the option ==")
h.options.overworld_mon_sprites = false
local offPika = build("POKEMON_FAN_CLUB",
  { index = 9, x = 6, y = 4, sprite = "SPRITE_FAIRY", movement = "STAY",
    range = "LEFT", name = "POKEMONFANCLUB_PIKACHU" })
check("option off: the cart's sheet is left alone", not isFollowerArt(offPika), sheet(offPika))
before = #h.drawn
pika.sprite:draw(96, 64, 0, 0, "down", 0, false)
check("option off: an already-built one draws vanilla too",
  h.drawn[#h.drawn].vanilla == true)
h.options.overworld_mon_sprites = true

print("\n== the mirror follows the engine's rules ==")
-- stepFlip is not a stride: an NPC toggles it when a step ENDS and then holds
-- it while standing, so mirroring on the flag alone leaves a standing POKeMON
-- mirrored until its next step turns it back -- a sprite walking on the spot.
local function sx(npc, facing, walkPhase, stepFlip)
  local before = #h.drawn
  npc.sprite:draw(96, 64, 0, 0, facing, walkPhase, stepFlip)
  assert(#h.drawn > before, "nothing was drawn")
  return h.drawn[#h.drawn].sx
end
local function frameOf(npc, facing, walkPhase, stepFlip)
  npc.sprite:draw(96, 64, 0, 0, facing, walkPhase, stepFlip)
  return h.drawn[#h.drawn].quad[2] / 16
end

check("standing, stepFlip set: NOT mirrored", sx(pika, "down", 0, true) > 0,
  sx(pika, "down", 0, true))
check("standing, stepFlip clear: not mirrored", sx(pika, "down", 0, false) > 0)
check("stepping, stepFlip set: mirrored", sx(pika, "down", 1, true) < 0)
check("stepping, stepFlip clear: not mirrored", sx(pika, "down", 1, false) > 0)
check("facing up standing, stepFlip set: NOT mirrored", sx(pika, "up", 0, true) > 0)
check("facing right: mirrored at either phase",
  sx(pika, "right", 0, false) < 0 and sx(pika, "right", 1, false) < 0)
check("facing left: never mirrored",
  sx(pika, "left", 0, false) > 0 and sx(pika, "left", 1, false) > 0)

check("standing holds the STAND frame", frameOf(pika, "down", 0, true) == 0,
  frameOf(pika, "down", 0, true))
check("stepping picks the WALK frame", frameOf(pika, "down", 1, false) == 3,
  frameOf(pika, "down", 1, false))

print("\n== the follower itself (regression) ==")
-- a healthy lead the mod will pick up as the active follower
h.game.save.party = { { species = "CHARMANDER", hp = 20, otId = 1,
                        dvs = {}, catchRate = 1, level = 5 } }
local followerNPC = build("PALLET_TOWN",
  { index = 1, x = 5, y = 6, sprite = "SPRITE_PIKACHU", movement = "STAY",
    range = "DOWN", name = nil })
followerNPC.sprite.def = h.sprites.SPRITE_PIKACHU
before = #h.drawn
followerNPC.sprite:draw(80, 80, 0, 0, "down", 0, false)
check("the follower still draws through the mod, not the engine",
  h.drawn[#h.drawn].vanilla == nil)
check("...painting its own species' sheet",
  (h.drawn[#h.drawn].image or {}).path
    == (HERE .. "/../assets/sprites/follower_004.png"),
  (h.drawn[#h.drawn].image or {}).path)
check("...from the down-facing STAND frame",
  h.drawn[#h.drawn].quad[2] == 0, h.drawn[#h.drawn].quad[2])

-- walking left picks WALK.left (frame 5) and mirrors nothing
before = #h.drawn
followerNPC.sprite:draw(80, 80, 0, 0, "left", 1, false)
check("a walking follower picks WALK.left", h.drawn[#h.drawn].quad[2] == 5 * 16,
  h.drawn[#h.drawn].quad[2])

-- a fainted lead leaves the tile empty
h.game.save.party = { { species = "CHARMANDER", hp = 0, otId = 1,
                        dvs = {}, catchRate = 1, level = 5 } }
before = #h.drawn
followerNPC.sprite:draw(80, 80, 0, 0, "down", 0, false)
check("a fainted follower draws nothing at all", #h.drawn == before)

print("\n== never smaller than the art ==")

-- The sheets are 16x16 and that is the whole detail budget.  Scaling one UP by
-- a whole number keeps every pixel; scaling DOWN deletes rows.  At the old
-- 0.6875 floor a 16px sprite was resampled to 11px -- five rows and five
-- columns gone, and 67 of Bulbasaur's 138 opaque pixels with them -- so every
-- small POKeMON came out a flat blob with its legs merged and its outline
-- broken.  Every small POKeMON hit that floor, which is why it looked like the
-- art was two-colour rather than mangled.
-- The fixture ships no species records, and pokedexHeightMeters returns nil
-- without one -- which makes followerVisualScale answer a flat 1 and any
-- assertion about the floor vacuous.  So the heights go in first: the real
-- Pokedex feet and inches, which is what the rule is computed from.
do
  local scaleOf = h.mod.exports.followerVisualScale
  check("the mod publishes its size rule", type(scaleOf) == "function")

  local HEIGHTS = {           -- dex number, feet, inches
    BULBASAUR = { 1, 2, 4 }, CHARMANDER = { 4, 2, 0 }, SQUIRTLE = { 7, 1, 8 },
    PIKACHU = { 25, 1, 4 },  DIGLETT = { 50, 0, 8 },  MAGIKARP = { 129, 2, 11 },
    ONIX = { 95, 28, 10 },   SNORLAX = { 143, 6, 11 }, MEW = { 151, 1, 4 },
  }
  h.game.data.pokemon = h.game.data.pokemon or {}
  for name, v in pairs(HEIGHTS) do
    h.game.data.pokemon[name] =
      { dex = v[1], dexEntry = { heightFt = v[2], heightIn = v[3] } }
  end
  -- and the rule is behind POKEDEX SIZES, which the harness ships off; with it
  -- off followerVisualScale returns a flat 1 on its first line and every
  -- assertion below would pass without measuring anything
  local sizesWere = h.options.pokedex_follower_sizes
  h.options.pokedex_follower_sizes = true

  if type(scaleOf) == "function" then
    -- the heights have to actually reach the rule, or everything below is
    -- measuring the nil path again
    check("a tall POKeMON scales up", (tonumber(scaleOf("ONIX")) or 1) > 1,
          scaleOf("ONIX"))

    local worst, worstAt = math.huge, nil
    for name in pairs(HEIGHTS) do
      local sc = tonumber(scaleOf(name)) or 1
      if sc < worst then worst, worstAt = sc, name end
      check(name .. " draws on whole pixels", (16 * sc) % 1 == 0, 16 * sc)
    end
    check("nothing is drawn below its native 16px", worst >= 1,
          tostring(worstAt) .. " = " .. tostring(worst))
  end
  h.options.pokedex_follower_sizes = sizesWere
end

print("\n== restore ==")
h.mod.exports.restore()
local afterRestore = build("ROUTE_16",
  { index = 1, x = 26, y = 10, sprite = "SPRITE_SNORLAX", movement = "STAY",
    range = "DOWN", name = "ROUTE16_SNORLAX" })
check("after restore, NPC.new is vanilla again", not isFollowerArt(afterRestore), sheet(afterRestore))

print(string.format("\n%d/%d checks passed", checks - fails, checks))
os.exit(fails == 0 and 0 or 1)
