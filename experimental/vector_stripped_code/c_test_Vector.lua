-- FUNCTIONAL 
local plpath = require 'pl.path'
local ffi      = require 'lua/q_ffi'
local Vector   = require 'lua/c_Vector_stripped'
os.execute("rm -f _*")

local len  = 1
local vec_len = 64*64*1024+3
local addr = ffi.malloc(len * 4)
addr = ffi.cast("int32_t *", addr)

local sz_after = 32


local status
local x
for iter = 1, 100 do
  x = Vector({ field_type = "I4", is_nascent = true})
  for i = 1, vec_len do 
    local after = ffi.new("char[?]", sz_after)
    addr[0] = i*10
    local before = tonumber(addr[0])
    x:set(addr, nil, len)
  end
  print("=== Created vector ===", iter)

  if ( ( iter %  8 ) == 0 ) then
    print("GARBAGE COLLECTION")
    collectgarbage()
  end
end
--====================================
os.exit()
