local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'

--
x = lVector(
{ qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
assert(x:check())
len, base_addr, nn_addr = x:get_all()
assert(len == 10)
assert(base_addr)
assert(nn_addr)
X = ffi.cast("int32_t *", base_addr)
for i = 1, 10 do
  print(X[i-1])
  assert(X[i-1] == i*10)
end
-- =========
print("Completed ", arg[0])
os.exit()
