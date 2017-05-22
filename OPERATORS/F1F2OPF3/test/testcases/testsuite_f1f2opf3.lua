local assert_valid = require 'assert_valid'
local promote = require 'promote'

local a_add = {10, 20, 30, 40, 50, 60}
local b_add = {70, 80, 90, 10, 60, 60}
local z_add = "80,100,120,50,110,120,"
local z_add_I8 = "80LL,100LL,120LL,50LL,110LL,120LL,"
  
local a_sub = {70, 80, 90, 10, 60, 60}
local b_sub = {10, 20, 30, 40, 50, 60}
local z_sub = "60,60,60,-30,10,0,"
local z_sub_I8 = "60LL,60LL,60LL,-30LL,10LL,0LL,"
  
local a_mul = {1, 2, 3, 4, 5, 6}
local b_mul = {7, 8, 9, 1, 6, 6}
local z_mul = "7,16,27,4,30,36,"
local z_mul_I8 = "7LL,16LL,27LL,4LL,30LL,36LL,"
 
local a_div = {70, 80, 90, 80, 100, 60}
local b_div = {10, 20, 30, 40, 50, 60}
local z_div = "7,4,3,2,2,1,"
local z_div_I8 = "7LL,4LL,3LL,2LL,2LL,1LL,"
  
local op = { "vvadd", "vvsub", "vvmul", "vvdiv" }
local a_data = { vvadd = a_add, vvsub = a_sub, vvmul = a_mul, vvdiv = a_div }
local b_data = { vvadd = b_add, vvsub = b_sub, vvmul = b_mul, vvdiv = b_div }
local z_data = { vvadd = z_add, vvsub = z_sub, vvmul = z_mul, vvdiv = z_div }
local z_data_I8 = { vvadd = z_add_I8, vvsub = z_sub_I8, vvmul = z_mul_I8, vvdiv = z_div_I8 }

local q_type = { "I1", "I2", "I4", "I8", "F4", "F8" }
local length = #q_type
  
local create_tests = function() 
  local tests = {}
  
  for i=1, #op do
    for j = 1, length do
      for k = 1, length do
        local input_type1 = q_type[j]
        local input_type2 = q_type[k]
        local result_type = promote(q_type[j], q_type[k])
        -- print(input_1, input_2, result_type)
        if result_type ~= nil then
          local expectedOut = z_data[op[i]]
          if (result_type == 'I8') then expectedOut = z_data_I8[op[i]] end
          table.insert(tests, {
            input = {op[i], input_type1, input_type2, a_data[op[i]], b_data[op[i]], result_type},
            check = assert_valid(expectedOut)
          })
        end
      end
    end
  end
  
  return tests
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