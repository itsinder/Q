local plpath  = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'

local fns =  require 'Q/experimental/lua-515/c_modules/lVector_test/assert_valid'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))

local assert_valid = function(test_type, test_name, gen_method, num_elements, field_size)
  return function (x)
    -- common checks for nascent and materialized vectors
    assert(x:check())
    
    -- calling the assert function based on type of vector
    local function_name = "assert_" .. test_type
    local status = fns[function_name](x, test_name, num_elements, field_size, gen_method)
    
    return status
  end
end

local create_tests = function() 
  local tests = {}  
  
  local T = dofile(script_dir .."/map_lVector.lua")
  for i, v in ipairs(T) do
    local qtype
    if v.qtype then qtype = v.qtype end
    for j in pairs(qtype) do
      local M
      if v.meta then
        M = dofile(script_dir .."/meta_data/"..v.meta)
      end
      M.qtype = qtype[j]
      local test_name = v.name .. "_" .. qtype[j]
      local num_elements = v.num_elements
      local field_size = qconsts.qtypes[M.qtype].width
      local gen_method
      if v.gen_method then gen_method = v.gen_method end
      table.insert(tests, {
        input = { M, gen_method, num_elements, field_size},
        check = assert_valid( v.test_type, test_name, gen_method, num_elements, field_size),
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