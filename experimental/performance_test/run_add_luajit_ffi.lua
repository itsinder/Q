local ffi = require 'ffi'
local header_file = "add.h"

local qc = ffi.load('./libadd.so')

local file = io.open(header_file, "r")
ffi.cdef(file:read("*all"))
file:close()

local function sum_of_n()
  local input = 100000000

  local output = qc['add'](input)
  --print(tonumber(output))
end

for i = 1, 100 do
  sum_of_n()
end

print("DONE")
