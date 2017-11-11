-- FUNCTIONAL

local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
require 'Q/UTILS/lua/strict'
local f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/f1f2opf3'
local testsuite_f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/c_testing/testsuite_f1f2opf3'
 
local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end
--[[ 
Refer comments in test_runner to understand the parameters of this function
suite: Suite as defined in test_runner
fn: Lua function to be tested
tests_to_run: OPTIONAL;table-array of test-numbers specifying which tests are to be run. If unspecified, all tests are run
--]]

local tests_to_run = {} 

for i=1,#testsuite_f1f2opf3.tests do 
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
    assert(testsuite_f1f2opf3.tests[test_num], "No test at index" .. test_num .. " in testsuite")
    test = testsuite_f1f2opf3.tests[test_num]
    print ("running test " .. test_num, test.name )
    --call_if_exists(test.setup)
    status, res = pcall(f1f2opf3, unpack(test.input))
    local result
    
    if status then
      result = test.check(res)
      -- preamble
      utils["testcase_results"](test, testsuite_f1f2opf3.test_for, testsuite_f1f2opf3.test_type, result, "")
      assert(result,"testcase " .. test.name .. " assertions failed")
      -- myassert (result, test_num, test.name)
    else      
      result = status
      -- preamble
      utils["testcase_results"](test, testsuite_f1f2opf3.test_for, testsuite_f1f2opf3.test_type, result, "")
      assert(result,"testcase " .. test.name .. " assertions failed")
      -- myassert (result, test_num, test.name, res)
    end
    --call_if_exists(test.teardown)
  end
end
  --call_if_exists(suite.teardown)
return test_suite