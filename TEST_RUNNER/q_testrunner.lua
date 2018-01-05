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

local run_tests = function(suite_name, test_name)
  local base_str =  [[luajit -lluacov -e "require '%s'[%s]();os.exit(0)" &>/dev/null]]
  local suite_name_mod, subs = suite_name:gsub("%.lua$", "")
  assert(subs == 1, suite_name .. " should end with .lua")
  local status, tests = pcall(dofile, suite_name)
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
    if tests.test_name == nil or type(tests.test_name) ~= "function" then
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
      table.insert(fail, k) end
    end
    return pass, fail
  end

  local run_suite = function(suite_name, test_name)
    print ("Running suite " .. suite_name .. "...")
    return run_tests(suite_name, test_name)
  end

  local usage = function()
    print("USAGE:")
    print("luajit q_testrunner.lua <root_dir>")
    print("luajit q_testrunner.lua <suite_file> [<test_case_id>]")
  end

  local plpath = require 'pl.path'
  local plpretty = require "pl.pretty"
  local q_root = assert(os.getenv("Q_ROOT"))
  assert(plpath.isdir(q_root))
  assert(plpath.isdir(q_root .. "/data/"))
  os.execute("rm -r -f " .. q_root .. "/data/*")
  require('Q/UTILS/lua/cleanup')()

  local path = arg[1]
  local test_name = arg[2]
  arg = nil
  local test_res = {}

  if (path and plpath.isfile(path)) then
    test_res[path] = {}
    test_res[path].pass,test_res[path].fail = run_suite(path, test_name)
  else
    -- run all tests in a DIR, either custom or default Q_SRC_ROOT
    if not (path and plpath.isdir(path)) then
      usage()
      os.exit()
    end
    print ("Discovering and running all test suites under " .. path)
    local files = (require "Q/TEST_RUNNER/q_test_discovery")(path)
    for _,f in pairs(files) do
      test_res[f] = {}
      test_res[f].pass, test_res[f].fail = run_suite(f)
    end
    -- TODO?
    --utils["testcase_results"](test, suite.test_for, suite.test_type, result, "")
  end
  print(plpretty.write(test_res))

  for k,v in pairs(_G) do
    if (k == 'test_aux') then test_aux(test_res) end
  end
