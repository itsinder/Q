--[[
Expected to be run as a command line program; takes two arguments
"funcUnderTest" and "testSuite".
Convention assumption: "funcUnderTest".lua is a module that returns the function to be tested. This is in accordance with the convention we're following for Q modules.

"testSuite": When this is "require"d it should return an array of "test"s, where
"test" is as defined below.

"test": A test is table with below structure
{
  "input": {...array of parameters to test function ...}
  "fail": "<expected substring of error message in case of a failure test-case>"
  "check": <callback function that is called with the output of invoking test-function>
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
require 'permute' 
require 'pl.path'

print ("Function under test: " .. arg[1])
print ("Test suite: " .. arg[2])

local fn = require (arg[1])
local suite = require (arg[2])

local failures = suite_runner(suite, fn)
if (#failures > 0) then
  print ("Failed tests: " .. tostring(failures))
else
  print("Tests passed.")
end