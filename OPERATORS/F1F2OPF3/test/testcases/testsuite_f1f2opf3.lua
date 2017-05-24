local assert_valid = require 'assert_valid'
local promote = require 'promote'

-- input data for add operation. a = first input, b = second input, z = output
local a_add = {10, 20, 30, 40, 50, 60}
local b_add = {70, 80, 90, 10, 60, 60}
local z_add = {80, 100, 120, 50, 110, 120}
  
-- input data for sub operation. a = first input, b = second input, z = output
local a_sub = {70, 80, 90, 10, 60, 60}
local b_sub = {10, 20, 30, 40, 50, 60}
local z_sub = {60, 60, 60, -30, 10, 0}
  
-- input data for multiply operation. a = first input, b = second input, z = output
local a_mul = {1, 2, 3, 4, 5, 6}
local b_mul = {7, 8, 9, 1, 6, 6}
local z_mul = {7, 16, 27, 4, 30, 36}
 
-- input data for division operation. a = first input, b = second input, z = output
local a_div = {70, 80, 90, 80, 100, 60}
local b_div = {10, 20, 30, 40, 50, 60}
local z_div = {7, 4, 3, 2, 2, 1}
  
-- input data for equal operation. a = first input, b = second input, z = output
local a_eq = {10, 20, 30, 50, 50, 60}
local b_eq = {10, 20, 30, 50, 50, 60}
local z_eq = {63}

-- input data for greater than or equal to  operation. a = first input, b = second input, z = output
local a_geq = {10, 22, 32, 52, 52, 61}
local b_geq = {10, 25, 30, 50, 50, 60}
local z_geq = {63}

-- list of qtypes to be operated on
--local q_type = { "I1", "I2", "I4", "I8", "F4", "F8" }
local q_type = { "I1" }
local length = #q_type
 
-- list of operations
--local op = { "vvadd", "vvsub", "vvmul", "vvdiv" }
local op = { "vveq" }

local a_data =  { vvadd = a_add, 
                  vvsub = a_sub, 
                  vvmul = a_mul, 
                  vvdiv = a_div, 
                  vveq = a_eq, 
                  vvgeq = a_geq 
                }
                
local b_data =  { vvadd = b_add, 
                  vvsub = b_sub, 
                  vvmul = b_mul, 
                  vvdiv = b_div, 
                  vveq = b_eq,
                  vvgeq = b_geq
                }
                
local z_data =  { vvadd = z_add, 
                  vvsub = z_sub, 
                  vvmul = z_mul, 
                  vvdiv = z_div, 
                  vveq = z_eq,
                  vvgeq = z_geq
                }

local assert_fn = { vvadd = assert_valid["assert_qtype"],
                    vvsub = assert_valid["assert_qtype"],
                    vvmul = assert_valid["assert_qtype"],
                    vvdiv = assert_valid["assert_qtype"],
                    vveq = assert_valid["assert_bit"],
                    vvgeq = assert_valid["assert_bit"]
                  }
                  
-- this table is used to determine the qtype of output. 
-- if its a function promote, then the qtype of output will be the result of promote function.
-- if not, then qtype of output is uint64_t
local z_type =  { vvadd = promote,
                  vvsub = promote,
                  vvmul = promote,
                  vvdiv = promote
                }
 
local create_tests = function() 
  local tests = {}
  
  for i=1, #op do
    for j = 1, length do
      for k = 1, length do
        local input_type1 = q_type[j]
        local input_type2 = q_type[k]
        local result_type 
        local test_name = op[i] .. "_" .. input_type1 .. "_" .. input_type2
        if type(z_type[op[i]]) == "function" then
          -- set result type to output of promote function
          result_type = z_type[op[i]](q_type[j], q_type[k])
          test_name = test_name .. "_" .. result_type
        else
          -- set result type to 0. 
          -- this result type will be converted to uint64_t.
          -- which is used in =, >=, <= etc. operators.
          result_type = 0
        end
        
        --print(result_type)
        if result_type ~= nil then
          local expectedOut = z_data[op[i]]
          table.insert(tests, {
            input = {op[i], input_type1, input_type2, a_data[op[i]], b_data[op[i]], result_type},
            check = assert_fn[op[i]](expectedOut),
            name = test_name
          })
        end
      end
    end
  end
  
  return tests
end

local suite = {}
suite.tests = create_tests()
--require 'pl'
--pretty.dump(suite.tests)
-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end
suite.filename = "f1f2opf3.lua"
suite.test_for = "F1F2OPF3"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite