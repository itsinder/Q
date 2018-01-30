local Q		= require 'Q'
local qc	= require 'Q/UTILS/lua/q_core'
local ffi	= require 'Q/UTILS/lua/q_ffi'
local qconsts	= require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}
local BUFLEN = 1024

tests.t1 = function()
  local len = 10

  -- Prepare input buffer
  local X = ffi.malloc(len * ffi.sizeof("int32_t"))
  X = ffi.cast("int32_t *", X)
  for i = 0, len - 1 do
    X[i] = 10 * (i + 1)
  end

  print("################################")
  print("Printing input buffer contents")
  for i = 0, len - 1 do
    print(X[i])
  end
  print("################################\n")

  -- Prepare output buf
  local buf = ffi.malloc(BUFLEN)
  local buf_copy = ffi.cast("char *", buf)
  ffi.fill(buf_copy, BUFLEN)

  -- Call I4_to_txt
  local status = 0
  print("Converted values are")
  for i = 0, len - 1 do
    ffi.fill(buf_copy, BUFLEN)
    status = qc.I4_to_txt(X + i, nil, buf_copy, BUFLEN-1);
    if status == 0 then
      print(ffi.string(buf))
    else
      print("Error")
    end
  end
  print("################################")
end

return tests
