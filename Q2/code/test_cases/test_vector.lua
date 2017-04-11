local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"

require 'globals'
local dir = require 'pl.dir'
local Vector = require 'Vector'

require 'handle_category'

local bin_file_path = "./bin/"

-- common setting (SET UPS) which needs to be done for all test-cases
dir.makepath(bin_file_path)

local handle_function = {}
-- handle random file generation testcase
handle_function["category1"] = handle_category1
-- handle invalid length vectors
handle_function["category2"] = handle_category2


local T = dofile("map_vector.lua")
for i, v in ipairs(T) do
  
  local arg_field_type = v.field_type
  local arg_field_size = g_qtypes[arg_field_type].width
  local arg_chunk_size = v.chunk_size 
  local arg_filename 
  if v.filename ~= nil then
    arg_filename = bin_file_path..v.filename
    v.filename= arg_filename
  end
  local arg_write_vector = v.write_vector
  local arg_input_values = v.input_values


  local v1 = Vector{ field_type = arg_field_type, field_size = arg_field_size, chunk_size = arg_chunk_size,
                     filename = arg_filename, write_vector = arg_write_vector
                   }

    
  if handle_function[v.category] then
    --print (handle_function[v.category])
    handle_function[v.category](i,v, v1, arg_input_values)
  end

end

print_result()


-- common cleanup (TEAR DOWN) for all testcases
--dir.rmtree(bin_file_path)