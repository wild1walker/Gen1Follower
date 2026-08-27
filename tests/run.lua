-- Every test in this directory, from the repository root:
--
--   lua5.4 tests/run.lua
--
-- Each file runs in its own process-like scope because the harness loads
-- main.lua fresh and the mod installs global wrappers; G1F_TEST_GEN picks
-- which generation the stubbed engine reports.
local suites = {
  { file = "tests/overworld_mons_test.lua", gen = "1", name = "map POKeMON, Gen 1" },
  { file = "tests/overworld_mons_gen2_test.lua", gen = "2", name = "map POKeMON, Gold" },
}

local lua = arg[-1] or "lua5.4"
local failed = 0
for _, suite in ipairs(suites) do
  print(("\n=== %s (%s) ==="):format(suite.name, suite.file))
  local cmd = ("G1F_TEST_GEN=%s %s %s"):format(suite.gen, lua, suite.file)
  local ok, how, code = os.execute(cmd)
  if not (ok == true or ok == 0) then
    failed = failed + 1
    print(("!!! %s failed (%s %s)"):format(suite.file, tostring(how), tostring(code)))
  end
end

if failed > 0 then
  print(("\n%d suite(s) failed"):format(failed))
  os.exit(1)
end
print("\nall suites passed")
