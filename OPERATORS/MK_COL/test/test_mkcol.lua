local mk_col = require 'mk_col'
local q_core = require 'q_core'

-- input table of values 1,2,3 of type I4, given to mk_col
local status, ret = pcall(mk_col, {1,3,4}, "I4")
-- local status, ret = pcall(mk_col, {1.1,5.1,4.5}, "F4")
assert(status, "Error in mk col ")
assert(type(ret) == "Column", " Output of mk_col is not Column")
for i=1,ret:length() do  
  local result = ret:get_element(i-1)
  local ctype =  g_qtypes[ret:fldtype()]["ctype"]
  local str = q_core.cast(ctype.." *",result)
  print(str[0])
end    
