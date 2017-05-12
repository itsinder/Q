local expand_tests = require 'expand_tests'
local assert_valid = require 'assert_valid'

local create_tests = function() 
  local tests = {}
  
  local a = {10, 20, 30, 40, 50, 60}
  local b = {70, 80, 90, 100, 110, 120}
  expand_tests(tests, {a, b}, {"I1", "I2"}, "80,100,120,140,160,180,", assert_valid)
  expand_tests(tests, {a, b}, {"I1", "I4"}, "80,100,120,140,160,180,", assert_valid)
  expand_tests(tests, {a, b}, {"I1", "I8"}, "80,100,120,140,160,180,", assert_valid)
  expand_tests(tests, {a, b}, {"I2", "I4"}, "80,100,120,140,160,180,", assert_valid)
  expand_tests(tests, {a, b}, {"I2", "I8"}, "80,100,120,140,160,180,", assert_valid)
  expand_tests(tests, {a, b}, {"I4", "I8"}, "80,100,120,140,160,180,", assert_valid)
  
  return {
    unpack(tests)
  }
end

local suite = {}
suite.tests = create_tests()
require 'pl'
pretty.dump(suite.tests)
-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite