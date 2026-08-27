-- Every suite in this directory:
--
--   lua5.4 tests/run.lua        (luajit tests/run.lua works too)
--
-- Each suite runs in its own process because the harness loads main.lua fresh
-- and the mod installs wrappers onto the engine tables it is handed.
--
-- The suites are self-contained -- each finds the harness from its own path
-- and names its own generation -- so the bundle repositories, which run every
-- vendored mod's tests/*.lua directly, get the same result this does. This
-- runner is a convenience, not the only way in.
local HERE = (arg and arg[0] or ""):match("^(.*)[/\\][^/\\]*$") or "."

local suites = {
  { file = "overworld_mons_test.lua", name = "map POKeMON, Gen 1" },
  { file = "overworld_mons_gen2_test.lua", name = "map POKeMON, Gold" },
}

local lua = arg and arg[-1] or "lua5.4"
local failed = 0
for _, suite in ipairs(suites) do
  print(("\n=== %s (tests/%s) ==="):format(suite.name, suite.file))
  local ok = os.execute(("%s %s/%s"):format(lua, HERE, suite.file))
  -- 5.1 hands back a status number; 5.4 hands back a boolean and a reason.
  if not (ok == true or ok == 0) then
    failed = failed + 1
    print(("!!! tests/%s failed"):format(suite.file))
  end
end

if failed > 0 then
  print(("\n%d suite(s) failed"):format(failed))
  os.exit(1)
end
print("\nall suites passed")
