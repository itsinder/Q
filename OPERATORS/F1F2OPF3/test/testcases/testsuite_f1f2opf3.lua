local assert_valid = require 'assert_valid'
local promote = require 'promote'

-- list of qtypes to be operated on
--local q_type = { "I1", "I2", "I4", "I8", "F4", "F8" }
local q_type = { "I1" }
local length = #q_type
 
local op = { 
  vvadd = { 
            data = {
              { a = {10,20,30,40}, b = {10,20,30,40}, z = {20,40,60,80}, check = "qtype" },
              { a = {10,20,30,40}, b = {10,20,30,40}, z = {20,40,60,80}, check = "qtype" },
            }, 
            output_ctype = "auto"
          },
          
  vveq =  { 
            data = {
              { a = {10,20,30,40}, b = {10,20,30,40}, z = {15}, check = "bit" },
            }, 
            output_ctype = "uint64_t"
          },
          
}
                   
local create_tests = function() 
  local tests = {}
  
  for i,v in pairs(op) do
    for j = 1, length do
      for k = 1, length do
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
          for m, n in pairs(op[i].data) do
            local expectedOut = n.z
            local check_fn 
            local fail_str
            if n.check then check_fn = assert_valid["assert_" .. n.check](expectedOut) end
            if n.fail then fail_str = n.fail end 
            table.insert(tests, {
              input = {i, input_type1, input_type2, n.a, n.b, result_type},
              check = check_fn,
              fail = fail_str,
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
suite.filename = "f1f2opf3.lua"
suite.test_for = "F1F2OPF3"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite