require 'mk_col'
require 'handle_category'



local handle_function = {}
-- handle error message testcases
handle_function["category1"] = handle_category1
-- handle 1D output regex.
handle_function["category2"] = handle_category2

-- loop through testcases
-- these testcases output error messages
local T = dofile("map_mkcol.lua")
for i, v in ipairs(T) do
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  print("--------------------------------")
  local input = v.input
  local qtype = v.qtype
  
  local status, ret = pcall(mk_col,input,qtype)
  if handle_function[v.category] then
    handle_function[v.category](i, v, status, ret)
  end
  ::skip::
end

print_result()
