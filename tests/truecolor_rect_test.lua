-- The exempt rectangle a full-colour overworld sprite asks for.
--
-- A trueColor rect is spliced onto the frame's zone list and re-blits its
-- region RAW, out of the colorize pass.  Renderer.scissorClamped rounds every
-- zone OUTWARD on purpose -- floor the near edge, ceil the far one, plus
-- SCISSOR_PIXEL_BIAS -- so two SGB zones share an edge rather than letting the
-- letterbox show through between them (#373).
--
-- Right for zones, wrong for this.  An exempt region wider than the sprite
-- leaves a ring of BACKGROUND out of the colorize pass, and while the ground
-- around the sprite looks much the same either way nobody sees it.  Then a
-- battle wipes the screen, the ground goes and the ring does not, and it is a
-- square outline around the character -- reported as exactly that, in
-- ADVANCED, the one mode where honorsTrueColor() splices these at all.
--
-- The rect used to round outward here too (floor the origin, ceil the size),
-- so it was a pixel proud of the sprite before the scissor made it prouder.
-- What this file holds is the invariant that fixes it: the rect is a SUBSET
-- of the sprite's own footprint, with a pixel of margin for the scissor to
-- round back out into.
--
-- Run:  lua5.4 tests/truecolor_rect_test.lua
local HERE = (arg and arg[0] or ""):match("^(.*)[/\\][^/\\]*$") or "."
local h = assert(loadfile(HERE .. "/support/harness.lua"))(HERE .. "/..", 1)

local fails, checks = 0, 0
local function check(name, cond, extra)
  checks = checks + 1
  if cond then print("  ok   " .. name)
  else fails = fails + 1; print("  FAIL " .. name .. (extra and ("  <- " .. tostring(extra)) or "")) end
end

local rectFor = h.mod.exports.trueColorRect
check("the rect is exported", type(rectFor) == "function")

-- The sprite is drawn pivoted at its feet: anchorX is its horizontal centre,
-- anchorY its baseline, so it spans [anchorX - w/2, anchorX + w/2] across and
-- [anchorY - h, anchorY] down.  Everything below is measured against that.
local function spans(anchorX, anchorY, w, h_)
  return anchorX - w / 2, anchorY - h_, anchorX + w / 2, anchorY
end

local function insideSprite(anchorX, anchorY, w, h_)
  local x, y, rw, rh = rectFor(anchorX, anchorY, w, h_)
  if not x then return nil end
  local left, top, right, bottom = spans(anchorX, anchorY, w, h_)
  return x >= left and y >= top and x + rw <= right and y + rh <= bottom,
         { x = x, y = y, w = rw, h = rh }
end

print("== a whole-pixel sprite, which is the ordinary case ==")
do
  -- 16x16 at scale 1, feet at (72, 96): the cell runs x 64..80, y 80..96.
  local x, y, w, hh = rectFor(72, 96, 16, 16)
  check("the rect starts inside the left edge", x == 65, x)
  check("and inside the top", y == 81, y)
  check("it stops inside the right edge", x + w == 79, x + w)
  check("and inside the bottom", y + hh == 95, y + hh)
  local ok = insideSprite(72, 96, 16, 16)
  check("so the whole rect is inside the sprite", ok)
end

print("== and a sprite on a fractional pixel, which is the one that spilled ==")
do
  -- A camera mid-scroll puts the anchor on a half pixel.  The old rounding
  -- (floor the origin, ceil the size) pushed the rect OUT on both sides here;
  -- this is the case the outline was drawn from.
  for _, offset in ipairs({ 0.5, 0.25, 0.75, 0.1, 0.9 }) do
    local ax, ay = 72 + offset, 96 + offset
    local ok, r = insideSprite(ax, ay, 16, 16)
    check(("inside the sprite at +%.2f"):format(offset), ok,
      r and ("rect " .. r.x .. "," .. r.y .. " " .. r.w .. "x" .. r.h))
  end
end

print("== a scaled sprite keeps the same promise ==")
do
  for _, scale in ipairs({ 1, 1.5, 2, 3 }) do
    local w = 16 * scale
    local ok, r = insideSprite(72, 96, w, w)
    check(("inside the sprite at scale %.1f"):format(scale), ok,
      r and ("rect " .. r.x .. "," .. r.y .. " " .. r.w .. "x" .. r.h))
  end
end

print("== and a sprite too small to inset asks for nothing ==")
do
  -- Two pixels of inset off a two-pixel sprite is not a rectangle.  Marking
  -- an empty or inside-out one would be worse than marking none: markTrueColor
  -- drops w<=0, but a 1x1 that rounds out to 3x3 is the bug in miniature.
  check("a 2x2 sprite gets no rect", rectFor(72, 96, 2, 2) == nil)
  check("nor does a 1x1", rectFor(72, 96, 1, 1) == nil)
  check("a 4x4 does", rectFor(72, 96, 4, 4) ~= nil)
end

print(("\n%d/%d checks passed%s  (Gen1Follower trueColor rect)")
  :format(checks - fails, checks, fails > 0 and (", " .. fails .. " FAILURES") or ""))
os.exit(fails == 0 and 0 or 1)
