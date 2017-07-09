-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local plfile = require 'pl.file'
local pldir  = require 'pl.dir'
local qc = require 'Q/UTILS/lua/q_core'
-- This tests whether garbage collection is happening as expected
-- If it were not, this would/should blow through your system's memory
local ffi = require 'Q/UTILS/lua/q_ffi'

for iter = 1, 4 do 
  local X = {}
  for i = 1, 4 do 
    local filename = "./__junk__" .. tostring(i) .. ".bin"
    plfile.write(filename, tostring(i))
    local mmap = ffi.gc(qc.f_mmap(filename, true), qc.f_munmap)
    assert(mmap.status == 0, "Mmap failed")
    X[i] = mmap
  end
  local n = collectgarbage("count")
  print(" Iter/n ", iter, n)
end
local n = collectgarbage("collect")
assert(n == 0)
local D = pldir.getfiles("./", "*.bin")
print(D)
assert(#D == 0)
-- os.execute("rm -f __*.bin")

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
os.exit()
