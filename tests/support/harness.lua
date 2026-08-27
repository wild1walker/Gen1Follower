-- A minimal gen1recomp stand-in: enough of the engine for Gen1Follower's entry
-- function to load and install its wrappers, so the map-POKeMON table and the
-- draw path can be exercised without the game. It is a stub, not the engine --
-- it proves which sheet an object is given and which draw path runs, and
-- nothing at all about how any of it looks on screen.
--
-- Runs under Lua 5.4 and under LuaJIT, which is what the bundle repositories
-- have. Run the suites from the repository root:  lua5.4 tests/run.lua
-- The repository root and the generation the stubbed engine reports, passed
-- in by the suite that loads this. A suite finds them from its OWN path, not
-- from the working directory: the bundle repositories run these files from
-- wherever they staged the mod, and a cwd-relative path fails there while
-- passing here.
local MODROOT, GEN = ...
MODROOT = MODROOT or "."
GEN = tonumber(GEN) or 1

local drawn = {}          -- what wrappedSpriteDraw painted, in order
local SpriteRenderer = {
  STAND = { down = 0, up = 1, left = 2, right = 2 },
  WALK  = { down = 3, up = 4, left = 5, right = 5 },
}
SpriteRenderer.__index = SpriteRenderer
function SpriteRenderer.new(def, seed)
  assert(type(def) == "table" and def.image, "sprite def needs an image")
  local frames = {}
  for f = 0, (def.frames or 1) - 1 do frames[f] = { frame = f } end
  return setmetatable({ def = def, seed = seed, frames = frames,
                        image = def.image }, SpriteRenderer)
end
function SpriteRenderer:draw(px, py, camX, camY, facing, walkPhase, stepFlip, ...)
  drawn[#drawn + 1] = { vanilla = true, id = self.def.id }
end
function SpriteRenderer:resolveImage() return self.image end

local NPC = {}
NPC.__index = NPC
function NPC.new(data, mapId, objDef)
  local def = data.sprites[objDef.sprite]
  assert(def, "unknown sprite " .. tostring(objDef.sprite))
  return setmetatable({ def = objDef, id = mapId .. "_obj_" .. objDef.index,
                        sprite = SpriteRenderer.new(def, mapId) }, NPC)
end

-- Gold's own NPC class: only the bounce frame matters here
local Gen2NPC = {}
Gen2NPC.__index = Gen2NPC
function Gen2NPC:bounceFrame()
  if not self.bouncing then return nil end
  if self.frozen then return 0 end
  return self.raised and 1 or 0
end

local PaletteFX = {
  redrawn = {},
  honorsTrueColor = function() return true end,
  shadeMap = function() return nil end,
  darkWorld = function() return false end,
  markTrueColor = function() end,
  dmgObj = function() return {} end,
}
function PaletteFX.markSpriteRedraw(img, quad, x, y, sx)
  drawn[#drawn + 1] = { image = img, quad = quad, x = x, y = y, sx = sx }
end

local Assets = {
  image = function(path) return { path = path,
    getDimensions = function() return 16, 96 end } end,
  imageData = function(path) return nil end,
  register = function() end,
}

local PikachuFollower = {
  update = function() end, onMapEntered = function() end,
  talk = function() end, starterInParty = function() end,
  setShouldSpawn = function(fn) return function() return false end end,
}

local stubs = {
  ["src.core.GameVersion"] = { get = function() return GEN == 2 and "gold" or "red" end,
    generation = function() return GEN end, isYellow = function() return false end },
  ["src.render.PaletteFX"] = PaletteFX,
  ["src.render.SpriteRenderer"] = SpriteRenderer,
  ["src.render.Assets"] = Assets,
  ["src.world.PikachuFollower"] = PikachuFollower,
  ["src.core.Strings"] = setmetatable({}, { __call = function(_, s) return s end }),
  ["src.core.Sound"] = {},
  ["src.render.TextBox"] = {},
  ["src.ui.PartyMenu"] = {},
  ["src.world.OverworldController"] = { talkTo = function() end },
  ["src.world.NPC"] = NPC,
  ["src.world.gen2.Npc"] = Gen2NPC,
}
local realRequire = require
require = function(name)
  if stubs[name] then return stubs[name] end
  error("no stub for " .. tostring(name), 2)
end

-- love: enough for the scaled/true-colour branches to run
love = {
  graphics = {
    newQuad = function(x, y, w, h) return { x, y, w, h } end,
    draw = function(img, quad, x, y, r, sx, sy, ox, oy)
      drawn[#drawn + 1] = { image = img, quad = quad, x = x, y = y, sx = sx, sy = sy }
    end,
    setColor = function() end,
    getColor = function() return 1, 1, 1, 1 end,
  },
  math = { random = function() return 1 end },
}

-- the mod handle
local options = { overworld_mon_sprites = true, pokedex_follower_sizes = false }
local Registry = {}
Registry.__index = Registry
local function registry() return setmetatable({ store = {} }, Registry) end
function Registry:get(id) return self.store[id] end
function Registry:register(id, v) self.store[id] = v end
function Registry:patch(id, v)
  local cur = self.store[id] or {}
  for k, val in pairs(v) do cur[k] = val end
  self.store[id] = cur
end
function Registry:override(id, v) self.store[id] = v end
function Registry:each() return pairs(self.store) end

local spritesRegistry = registry()
local game = { data = { pokemon = {} }, save = { party = {} } }
if GEN == 2 then game.data.gen2Sprites = spritesRegistry.store
else game.data.sprites = spritesRegistry.store end
local mod = {
  id = "Gen1Follower",
  path = MODROOT,
  game = game,
  options = {
    define = function() end,
    get = function(_, key) return options[key] end,
  },
  content = { sprites = spritesRegistry, icons = registry(),
              pokemon = registry() },
  hooks = { wrap = function() end },
  events = { on = function() end, once = function() end },
  exports = {},
  log = { info = function() end, warn = function() end, error = function() end },
  find = function() return nil end,
}

-- the vanilla sheets the maps ship with
for _, id in ipairs({ "SPRITE_MONSTER", "SPRITE_BIRD", "SPRITE_FAIRY",
                      "SPRITE_SEEL", "SPRITE_SNORLAX", "SPRITE_POKE_BALL",
                      "SPRITE_GENTLEMAN", "SPRITE_PIKACHU", "SPRITE_CHANSEY" }) do
  spritesRegistry.store[id] = { id = id,
    image = "assets/generated/sprites/" .. id:lower() .. ".png",
    frames = id == "SPRITE_SNORLAX" and 1 or 6,
    walker = id ~= "SPRITE_SNORLAX" }
end

local chunk = assert(loadfile(MODROOT .. "/main.lua"))
local entry = chunk()
entry(mod)

require = realRequire
return { mod = mod, NPC = NPC, Gen2NPC = Gen2NPC, PikachuFollower = PikachuFollower,
         sprites = spritesRegistry.store,
         drawn = drawn, SpriteRenderer = SpriteRenderer, game = game,
         options = options }
