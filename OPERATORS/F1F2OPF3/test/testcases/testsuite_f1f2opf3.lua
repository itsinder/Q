-- list of qtypes to be operated on
local all_qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
-- data for each operator will be placed in test_<operator>.lua file
-- e.g. data for add operation is placed in test_vvadd.lua
local operators = {"vvadd", "vveq"}


-- assert function, to compare the expected and actual output 
local assert_valid = function(expected)
  return function (ret)
    for k,v in ipairs(ret) do
      --print ( ret[k], expected[k])
      if ret[k] ~= expected[k] then return false end
    end
    return true
  end
end
                   
local create_tests = function() 
  local tests = {}  
  for i in pairs(operators) do -- traverse every operation
    local M = dofile("test_" .. operators[i] .. ".lua")
    for m, n in pairs(M.data) do
      local q_type
      if n.qtype then q_type = n.qtype else q_type = all_qtype end
      for j in ipairs(q_type) do -- traverse every qtype
        for k in ipairs(q_type) do -- traverse every qtype
          local input_type1 = q_type[j]
          local input_type2 = q_type[k]
          local test_name = operators[i] .. "_" .. input_type1 .. "_" .. input_type2
          local expectedOut = n.z
          table.insert(tests, {
            input = {operators[i], input_type1, input_type2, n.a, n.b, M.output_ctype},
            check = assert_valid(expectedOut),
            --fail = fail_str,
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

suite.test_for = "F1F2OPF3"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite