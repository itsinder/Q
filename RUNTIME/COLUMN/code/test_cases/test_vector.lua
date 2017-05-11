require 'globals'
local dir = require 'pl.dir'
local Vector = require 'Vector'
local fns = require 'handle_category'
local utils = require 'utils'

local bin_file_path = "./bin/"

-- common setting (SET UPS) which needs to be done for all test-cases
dir.makepath(bin_file_path)

local T = dofile("map_vector.lua")
for i, v in ipairs(T) do
  if arg[1]~= nil and tonumber(arg[1])~=i then goto skip end
  
  local arg_field_type = v.field_type
  local arg_field_size = v.field_size
  local arg_chunk_size = v.chunk_size 
  local result
  local arg_filename 
  if v.filename ~= nil then
    arg_filename = bin_file_path..v.filename
    v.filename= arg_filename
  end
  local arg_write_vector = v.write_vector
  local arg_input_values = v.input_values
  
  local input_argument
  if v.input_argument then
    input_argument = v.input_argument
  else
    input_argument = {field_type = arg_field_type, field_size = arg_field_size, 
      chunk_size = arg_chunk_size, filename = arg_filename, write_vector = arg_write_vector}
  end
  
  local status, v1 = pcall(Vector.new, input_argument)
  local key = "handle_"..v.category  
  if fns[key] then
     result = fns[key](i,v, status, v1, arg_input_values, arg_write_vector)
  else
    fns["increment_fail_testcases"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
    result = false
  end
  utils["testcase_results"](v, "test_vector.lua", "Vector", "Unit Test", result, "")
  ::skip::
end

fns["print_result"]()

-- common cleanup (TEAR DOWN) for all testcases
--dir.rmtree(bin_file_path)
