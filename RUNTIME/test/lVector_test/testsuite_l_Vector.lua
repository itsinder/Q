local plpath  = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'

local fns =  require 'Q/RUNTIME/test/lVector_test/assert_valid'

local script_dir = plpath.dirname(plpath.abspath(arg[1]))

local all_qtype = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8', 'SC', 'SV' }

local assert_valid = function(assert_fns, test_name, gen_method, num_elements)
  return function (x)
    -- calling the assert function based on type of vector
    local function_name = "assert_" .. assert_fns
    local status, result = pcall(fns[function_name], x, test_name, num_elements, gen_method)
    if not status then 
      print(result)
    end
    return status
  end
end

local create_tests = function() 
  local tests = {}  
  
  local T = dofile(script_dir .."/map_lVector.lua")
  for i, v in ipairs(T) do
    local qtype
    if v.qtype then qtype = v.qtype else qtype = all_qtype end
    for j in pairs(qtype) do
      local test_name = v.name .. "_" .. qtype[j]
      local M
      if v.meta then
        M = dofile(script_dir .."/meta_data/"..v.meta)
      end
      
      if v.test_type == "materialized_vector" and string.match( M.file_name,"${q_type}" ) then 
        M.file_name = string.gsub( M.file_name, "${q_type}", qtype[j] )
        M.file_name = script_dir .. "/" .. M.file_name
        if M.nn_file_name then
          M.nn_file_name = script_dir .. "/" .. M.nn_file_name
        end
      end
      M.qtype = qtype[j]
      
      if v.num_elements then
        M.num_elements = v.num_elements
      end
      local field_size = qconsts.qtypes[M.qtype].width
      
      local gen_method
      if v.gen_method then gen_method = v.gen_method end
      
      table.insert(tests, {
        input = { M },
        check = assert_valid( v.assert_fns, test_name, gen_method, v.num_elements),
        name = test_name,
      }) 
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

suite.test_for = "lVector"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite
