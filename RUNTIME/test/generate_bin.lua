local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local plpath  = require 'pl.path'
local fns = {}

fns.generate_bin = function (num_values, q_type, bin_filename, gen_type)
  local q_type_width = qconsts.qtypes[q_type].width
  if q_type == "B1" then
    num_values = math.ceil( num_values / 64 )
    q_type_width = 8
  end
  local buf = ffi.malloc(num_values * ffi.sizeof(qconsts.qtypes[q_type].ctype))
  buf = ffi.cast((qconsts.qtypes[q_type].ctype).." *", buf)

  for i = 1,num_values do
    local value 
    if q_type == "B1" then
      if i % 2 == 0 then value = 0 else value = 1 end  
    else
      if gen_type == "random" then
        value = i*15 % qconsts.qtypes[q_type].max
      elseif(gen_type == "iter")then 
        value = i * 10
      end
    end
    buf[i-1] = value
  end

  local fp = ffi.C.fopen(bin_filename, "w")
  -- print("L: Opened file")
  local nw = ffi.C.fwrite(buf, q_type_width, num_values , fp)
  -- print("L: Wrote to file")
  -- assert(nw > 0 )
  ffi.C.fclose(fp)
  --print("L: Done with file")
  assert(plpath.isfile(bin_filename))
end

return fns


