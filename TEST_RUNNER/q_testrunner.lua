--[[
For the purposes of this tool, below are axiomatic definitions:
"Test"/"Test case": A lua function that takes no arguments, and returns nothing. It is typically
expected that this function will test some behavior using assert's.

"Pass": A test is considered to pass if it returns successfully without any errors
"Fail": A test is considered to fail if it raises an error (typically due to a failed assert)

"Test suite": A .lua file that, when require'd, returns an table of test cases. For each entry of the
table, the key acts as the identifier/name of a test case, the value is the test case itself.
Note that the table can also be an array, in which case the index-into-array is the identifier for the
test cases in that suite.

Run luajit q_testrunner.lua to see its usage.

Update 16-Nov-2017:
If q_testrunner find a global variable called "test_aux", it invokes test_aux as a function, passing it the results as a parameter. When running from command line, use -l to load any aux functions that can initialize a global test_aux variable. Example is q_test_runner_auxsummary.lua
]]

local function is_polluter(file_name)
  local line
  file = assert( io.open(file_name, "r"), file_name .. " must exist")
  line = file:read()
  file:close()
  return line:match("POLLUTER") ~= nil
end

local function run_isolated_tests(suite_name, test_name, isolated)
  local base_str =  [[luajit -lluacov -e "require '%s'[%s]();os.exit(0)" &>/dev/null]]
  local suite_name_mod, subs = suite_name:gsub("%.lua$", "")
  assert(subs == 1, suite_name .. " should end with .lua")
  local status, tests = pcall(require, suite_name)
  if not status then
    return {}, { msg = "Failed to load suit\n" .. tostring(tests) }
  end
  if type(tests) ~= "table" then
    print("Test " .. suite_name .. "does not return a table of tests")
    return {}, {msg = suite_name .. " does not return a table"}
  end
  if (test_name) then
    local test_str
    if tonumber(test_name) == nil then
      test_str = string.format(base_str, suite_name_mod, "'" .. test_name .. "'")
    else
      test_str = string.format(base_str, suite_name_mod, test_name)
    end
    print("cmd:", test_str)
    local status = os.execute(test_str)
    if status == 0 then
      return {test_name}, {}
    end
    -- check if test exists or failed
    if tests[test_name] == nil or type(tests[test_name]) ~= "function" then
      print("Test " .. test_name .. " not found!")
      return {}, {msg = test_name .. " = Test Not Found"}
    end
    -- test failed
    return {}, {test_name}
  end
  local pass = {}
  local fail = {}
  for k,v in pairs(tests) do
    local test_str
    if tonumber(k) == nil then
      test_str = string.format(base_str, suite_name_mod, "'" .. k .. "'")
    else
      test_str = string.format(base_str, suite_name_mod, k)
    end
    print("cmd:", test_str)
    local status = os.execute(test_str)
    if status == 0 then
      table.insert(pass, k)
    else
      table.insert(fail, k)
    end
  end
  return pass, fail
end

local function run_longterm_tests(files, duration, log_path)
  local start_time =  os.time()
  local fail, pass = {}, {}
  repeat
    local file_id = math.random(#files)
    local suite_name = files[file_id]
    local suite_name_mod, subs = suite_name:gsub("%.lua$", "")
    assert(subs == 1, suite_name .. " should end with .lua")
    local status, tests = pcall(require, suite_name_mod)
    assert(type(tests) == "table", "A table of tests needs to be returned by " .. suite_name)
    -- get all keys from table so that we can randomly select from them
    local keyset = {}
    for k,v in ipairs(tests) do
      keyset[#keyset + 1] = k
    end
    local test_name = keyset[math.random(#keyset)]
    print("Running test %s from suite %s", test_name, suite_name)
    local status, msg = pcall(tests[test_name])
    if status then
      pass[#pass + 1] = {suite_name, test_name}
    else
      fail[#fail + 1] = {suite_name, test_name, msg}
    end
  until (os.time() - start_time) >= duration
  return pass, fail
end

local usage = function()
  print("USAGE:")
  print("luajit <option> q_testrunner.lua <root_dir>")
  print("luajit <option> q_testrunner.lua <suite_file> [<test_case_id>]")
  print (" Valid options are \n\t l for long running tests amd requires a time param for the number of minutes the tests should run. Eg l 5\n\t i for isolated tests")
end

local plpath = require 'pl.path'
local plpretty = require "pl.pretty"
local q_root = assert(os.getenv("Q_ROOT"))
assert(plpath.isdir(q_root))
assert(plpath.isdir(q_root .. "/data/"))
os.execute("rm -r -f " .. q_root .. "/data/*")
require('Q/UTILS/lua/cleanup')()

local test_type = arg[1]
local path = arg[2]
local test_name = arg[3]
args = nil
local test_res = {}
local files = {}
if (path and plpath.isfile(path)) then
  files[#files + 1] = path
else
  -- run all tests in a DIR, either custom or default Q_SRC_ROOT
  if not (path and plpath.isdir(path)) then
    usage()
    os.exit()
  end
  files = (require "Q/TEST_RUNNER/q_test_discovery")(path)

end
if test_type == "i" then
  for _,f in pairs(files) do
    test_res[f] = {}
    test_res[f].pass, test_res[f].fail = run_isolated_tests(f)
  end
elseif test_type:match("^l") ~= nil then
  local duration = tonumber(test_type:match("^l([0-9]+)$"))
  assert(duration ~= nil, "Must have a valid duration for the long term run")
  local long_files = {}
  for k,v in ipairs(files) do
    if is_polluter(v) == false then
      long_files[#long_files + 1] = v
    end
  end
  test_res.all = {}
  test_res.all.pass, test_res.all.fail = run_longterm_tests(long_files, duration, nil)
end
print(plpretty.write(test_res))

for k,v in pairs(_G) do
  if (k == 'test_aux') then test_aux(test_res) end
end
