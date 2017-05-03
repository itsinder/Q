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
  if arg[1]~= nil and tonumber(arg[1])~=i then 
    goto skip 
  end
  local arg_field_type = v.field_type
  local arg_field_size = g_qtypes[arg_field_type].width
  local arg_chunk_size = v.chunk_size 
  local result
  local arg_filename 
  if v.filename ~= nil then
    arg_filename = bin_file_path..v.filename
    v.filename= arg_filename
  end
  local arg_write_vector = v.write_vector
  local arg_input_values = v.input_values

  local v1 = Vector{ field_type = arg_field_type, field_size = arg_field_size, 
    chunk_size = arg_chunk_size, filename = arg_filename, write_vector = arg_write_vector
  }

  local key = "handle_"..v.category  
  if fns[key] then
     result = fns[key](i,v, v1, arg_input_values)
  else
    fns["increment_fail_testcases"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
    result = false
  end
  utils["testcase_results"](v, "test_vector.lua", "Vector", "Unit Test", result)
  ::skip::
end

fns["print_result"]()

-- common cleanup (TEAR DOWN) for all testcases
--dir.rmtree(bin_file_path)