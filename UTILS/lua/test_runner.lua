--[[
Expected to be run as a command line program; takes below arguments
    "funcUnderTest": Mandatory; is a module that returns the function to be tested. This is in accordance with the convention we're following for Q modules.
    "testSuite": Mandatory; this parameter, when "require"d, should return a "suite" as defined below
    "testsToRun": Optional; string representation of lua table-array e.g. {1,3} indicating which specific tests should be run from the suite. Note: if running from shell script, escape the braces e.g. \{1,3\}
--------
"suite": is a table with below structure
{
  "tests": {... array of "test" objects, see "test" definition below}
  "setup": <OPTIONAL; function to be called before the tests are executed>
  "teardown": <OPTIONAL; function to be called after the tests are executed>
}

"test": A test is table with below structure
{
  "input": {...array of parameters to test function ...}
  "fail": "<expected substring of error message in case of a failure test-case>"
  "check": <callback function that is called with the output of invoking test-function>
  "setup": <OPTIONAL; function to be called before this test is executed>
  "teardown": <OPTIONAL; function to be called after this test is executed>
}
"fail" and "check" are mutually exclusive, exactly one of them should be present in a test.

"fail" should be specified if and only if the invocation to funcUnderTest is expected to result in an error.
"check" should be a function that takes a single argument (actual result of invoking funcUnderTest) and does all validation checks. It should return a boolean - true if actual matches expected; false otherwise

This test_runner program runs all tests, and logs all failed test-cases with their number (index in tests array)
--]]

local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end

local suite_runner = function (suite, fn, tests_to_run)
  local status, res
  local failures = ""
  if tests_to_run == nil then
    tests_to_run = {}
    for i=1,#suite.tests do 
      table.insert(tests_to_run, i)
    end
  end
  
  local function myassert(cond, i, msg) 
    if not cond then 
      failures = failures .. i
      if msg then failures = failures .. "[" .. msg .. "],\n" end
    end
  end
  
  local test
  call_if_exists(suite.setup)
  
  for k,test_num in pairs(tests_to_run) do
    print ("running test " .. test_num)
    test = suite.tests[test_num]
    call_if_exists(test.setup)
    status, res = pcall(fn, unpack(test.input))

    if test.fail then
      myassert (status == false, test_num)
      myassert (string.match(res, test.fail), test_num)
    else
      if status then
        myassert (test.check(res), test_num)
      else      
        myassert (status, test_num, res)
      end
    end
    call_if_exists(test.teardown)
  end
  call_if_exists(suite.teardown)
  return failures
end

--print ("LUA PATH " .. package.path)
--print ("TERRA PATH" .. package.terrapath)

require 'globals'
require 'terra_globals'
require 'error_code'
local pretty = require 'pl.pretty'

print ("Function under test: " .. arg[1])
print ("Test suite: " .. arg[2])

local fn = require (arg[1])
local suite = require (arg[2])
local tests_to_run = arg[3]

if tests_to_run ~= nil then
  tests_to_run = assert(pretty.read(tests_to_run))
end

local failures = suite_runner(suite, fn, tests_to_run)
if (#failures > 0) then
  print ("Failed tests: " .. tostring(failures))
else
  print("Tests passed.")
end