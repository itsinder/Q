local mk_col = require 'mk_col'
local fns = require 'handle_category'

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
  if fns[v.category] then
    fns[v.category](i, v, status, ret)
  else
    fns["increment_failed_mkcol"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
  end
  ::skip::
end

fns["print_result"]()
