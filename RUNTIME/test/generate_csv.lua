local qconsts = require 'Q/UTILS/lua/q_consts'
local fns = {}

fns.generate_csv = function (csv_filename, qtype, no_of_rows )
  local file = assert(io.open(csv_filename, 'w'))
  for i = 1, no_of_rows do
    local value
    if qtype == "B1" then
      if i % 2 == 0 then value = 0 else value = 1 end  
    else
      value = i * 10
    end
    file:write(value.."\n")
  end
  file:close()
end

return fns


