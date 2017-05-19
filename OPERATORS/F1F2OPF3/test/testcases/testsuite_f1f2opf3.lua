local expand_tests = require 'expand_tests'
local assert_valid = require 'assert_valid'

local a_add = {10, 20, 30, 40, 50, 60}
local b_add = {70, 80, 90, 10, 60, 60}
local z_add = "80,100,120,50,110,120,"
  
local a_sub = {70, 80, 90, 10, 60, 60}
local b_sub = {10, 20, 30, 40, 50, 60}
local z_sub = "60,60,60,-30,10,0,"
  
local a_mul = {1, 2, 3, 4, 5, 6}
local b_mul = {7, 8, 9, 1, 6, 6}
local z_mul = "7,16,27,4,30,36,"
 
local a_div = {70, 80, 90, 10, 60, 60}
local b_div = {10, 20, 30, 40, 50, 60}
local z_div = "7,4,3,0,1,1,"
  
 
local create_tests = function() 
  local tests = {}
  
  -- addition testcases
  expand_tests(tests, "vvadd", {a_add, b_add}, {"I1", "I1"}, "I1", z_add, assert_valid)
  -- substraction testcases
  expand_tests(tests, "vvsub", {a_sub, b_sub}, {"I1", "I1"}, "I1", z_sub, assert_valid)
  -- multiplication testcases
  expand_tests(tests, "vvmul", {a_mul, b_mul}, {"I1", "I1"}, "I1", z_mul, assert_valid)
  -- division testcases
  expand_tests(tests, "vvdiv", {a_div, b_div}, {"I1", "I1"}, "I1", z_div, assert_valid)
  
  
  return {
    unpack(tests)
  }
end

local suite = {}
suite.tests = create_tests()
require 'pl'
--pretty.dump(suite.tests)
-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite