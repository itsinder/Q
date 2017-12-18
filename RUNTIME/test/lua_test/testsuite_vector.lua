local plpath  = require 'pl.path'
local dir = require 'pl.dir'
local qconsts = require 'Q/UTILS/lua/q_consts'

local fns =  require 'Q/RUNTIME/test/lua_test/assert_valid'
local gen_fns = require 'Q/RUNTIME/test/generate_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/RUNTIME/test/lua_test"
dir.makepath(script_dir .."/bin/")

local allowed_qtypes = {'I1', 'I2', 'I4', 'I8', 'F4', 'F8', 'SC', 'SV'}

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
  
  local T = dofile(script_dir .."/map_vector.lua")
  for i, v in ipairs(T) do
    if v.qtype then allowed_qtypes = v.qtype end
    for _, qtype in pairs(allowed_qtypes) do
      local test_name = v.name .. "_" .. qtype
      local M
      if v.meta then
        M = dofile(script_dir .."/meta_data/"..v.meta)
      end
      local csv_file_name
      local bin_file_name
      if v.test_type == "materialized_vector" then
        --print(qtype ..".csv", qtype, v.num_elements)
        csv_file_name = "bin/".. qtype .. ".csv"
        bin_file_name = "bin/in_".. qtype .. ".bin"
        --print(csv_file_name,bin_file_name, v.num_elements)
        gen_fns.generate_csv(csv_file_name, qtype, v.num_elements, "random")
        --print("../../../UTILS/src/asc2bin" .. csv_file_name .. qtype .. bin_file_name)
        local status = os.execute("../../../UTILS/src/asc2bin" .." ".. csv_file_name .. " " .. qtype .. " " .. bin_file_name)
        assert(status)
      end
      
      if v.test_type == "materialized_vector" and string.match( M.file_name,"${q_type}" ) then
        M.file_name = string.gsub( M.file_name, "${q_type}", qtype )
        M.file_name = script_dir .. "/" .. M.file_name
        if M.nn_file_name then
          M.nn_file_name = script_dir .. "/" .. M.nn_file_name
        end
      end
      
      M.qtype = qtype
      if v.num_elements then
        M.num_elements = v.num_elements
      end
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

-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end

suite.test_for = "vector"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite