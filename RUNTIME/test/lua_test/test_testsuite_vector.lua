-- FUNCTIONAL

local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
require 'Q/UTILS/lua/strict'
local vector = require 'Q/RUNTIME/test/lua_test/vector'
local testsuite_vector = require 'Q/RUNTIME/test/lua_test/testsuite_vector'
 
 
local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end
--[[ 
vector: Lua function to be tested
tests_to_run: OPTIONAL;table-array of test-numbers specifying which tests are to be run. If unspecified, all tests are run
--]]

local tests_to_run = {} 

for i=1,#testsuite_vector.tests do 
  table.insert(tests_to_run, i)
end
  
--[[
-- local failures = ""
local function myassert(cond, i, name, msg) 
  if not cond then
    failures = failures .. i
    if name then failures = failures .. ' - ' .. name .. '\n' end
    if msg then failures = failures .. "[" .. msg .. "],\n" end
  end
end
]]

local test_suite = {}
local status, res
local test
--call_if_exists(suite.setup)

for k,test_num in pairs(tests_to_run) do
  test_suite[test_num] = function()
    assert(testsuite_vector.tests[test_num], "No test at index" .. test_num .. " in testsuite")
    test = testsuite_vector.tests[test_num]
    print ("running test " .. test_num, test.name )
    --call_if_exists(test.setup)
    status, res = pcall(vector, unpack(test.input))
    local result
    
    if status then
      result = test.check(res)
      -- preamble
      utils["testcase_results"](test, testsuite_vector.test_for, testsuite_vector.test_type, result, "")
      assert(result,"testcase " .. test.name .. " assertions failed")
      -- myassert (result, test_num, test.name)
    else      
      result = status
      -- preamble
      utils["testcase_results"](test, testsuite_vector.test_for, testsuite_vector.test_type, result, "")
      assert(result,"testcase " .. test.name .. " assertions failed")
      -- myassert (result, test_num, test.name, res)
    end
    --call_if_exists(test.teardown)
  end
end
  --call_if_exists(suite.teardown)
return test_suite