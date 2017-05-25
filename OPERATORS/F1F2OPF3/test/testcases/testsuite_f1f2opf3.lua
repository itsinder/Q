local assert_valid = require 'assert_valid'
local promote = require 'promote'

-- list of qtypes to be operated on
local qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
--local qtype = { "I1" }
 
-- this table contains operation as key - vvadd, vvsub, vveq etc.
-- and other required information as data
-- output_ctype = auto if operation is add, sub, mut, div
-- output_ctype = "uint64_t" if operation is eq, neq, geq etc.
-- data field contain different input and output data for each operation.
-- if we want to test 3 different type of input data for add operation, then
-- add number of elements in data field of vvadd should be 3.
local op = { 
  vvadd = { 
            data = {
              { a = {10,20,30,40}, b = {10,20,30,40}, z = {20,40,60,80} }, -- simple values
              { a = {10,20,30,40}, b = {130,140,100,250}, z = {20,40,60,80} }, -- overflow
              -- only F4 and F8 type will be run for the below data
              { a = {10.1,20.2,30.2}, b = {10.5,20.3,30.3}, z = {20,40,60,80}, qtype = {"F4", "F8"} },  
            },
            output_ctype = "auto"
          },
          
  vveq =  { 
            data = {
              { a = {10,20,30,40}, b = {10,20,30,40}, z = {15} }, -- all equal
              { a = {20,20,30,40}, b = {10,20,30,40}, z = {14} }, -- 1st not equal
              { a = {10,20,30,50}, b = {10,20,30,40}, z = {7} }, -- 4th not equal
              { a = {10,20,40,40}, b = {10,20,30,40}, z = {11} }, -- 3rd not equal
              { a = {10,30,30,40}, b = {10,20,30,40}, z = {13} }, -- 2nd not equal
            },
            output_ctype = "uint64_t"
          },
          
}
                   
local create_tests = function() 
  local tests = {}
  
  for i in pairs(op) do -- traverse every operation
    for m, n in pairs(op[i].data) do
      local q_type
      if n.qtype then q_type = n.qtype else q_type = qtype end
      for j in ipairs(q_type) do -- traverse every qtype
        for k in ipairs(q_type) do -- traverse every qtype
          local input_type1 = q_type[j]
          local input_type2 = q_type[k]
          local result_type 
          local test_name = i .. "_" .. input_type1 .. "_" .. input_type2
          if op[i].output_ctype == "auto" then
            -- set result type to output of promote function
            result_type = promote(q_type[j], q_type[k])
            test_name = test_name .. "_" .. result_type
          else
            result_type = op[i].output_ctype
          end
          --print(result_type)
          if result_type ~= nil then
            local expectedOut = n.z
            table.insert(tests, {
              input = {i, input_type1, input_type2, n.a, n.b, result_type},
              check = assert_valid(expectedOut),
              --fail = fail_str,
              name = test_name
            })            
          end
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