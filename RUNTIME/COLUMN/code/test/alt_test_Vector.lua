require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi      = require 'Q/UTILS/lua/q_ffi'
local Vector   = require 'Q/RUNTIME/COLUMN/code/lua/alt_Vector'
os.execute("rm -f _*")

local x 
local idx 
local addr
local len  = 1
vec_len = 20000*qconsts.chunk_size+3
x = Vector({ field_type = "I4", is_nascent = true})
addr = ffi.malloc(len * qconsts.qtypes["I4"].width)
addr = ffi.cast("int32_t *", addr)
for i = 1, vec_len do 
  addr[0] = i*10
  x:set(addr, nil, len)
  print(i)
end
print("=== Created vector ===")
os.exit()
x:eov()
local T = x:meta()
assert(T.file_name)
assert(T.map_len == vec_len * ffi.sizeof("int32_t"))
for i = 1, vec_len do
  local addr = ffi.cast("int32_t *", x:get(i-1, 1))
  print(i, addr[0])
  if (addr[0] ~= i) then
    print("XX ", i, addr[0])
    os.execute("sleep 1000")
  end
  assert(addr[0] == i)
end


local T = x:internals()
for k,v in pairs(T) do print(k, v) end
print("SUCCESS for ", arg[0])
os.execute("rm -f _*")

-- x = nil

-- same as Vector.append(x, addr, idx, len)
