local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'Q/UTILS/lua/q_ffi'
os.execute("rm -f _*")

local file_name = ffi.malloc(32)
local nmemb = 65536*128
local size = ffi.sizeof("int32_t")
local addr = ffi.malloc(nmemb * size)
addr = ffi.cast("int32_t *", addr)
for i = 0, nmemb-1 do
  addr[i] = i+1
end
addr = ffi.cast("const char *", addr)

for i = 1, 128 do
  status = qc['rand_file_name'](file_name, 31)
  assert(status == 0)
  print(i, ffi.string(file_name))
  status = qc['buf_to_file'](addr, size, nmemb, file_name)
  assert(status == 0)
end
-- os.execute("rm -f _*")
