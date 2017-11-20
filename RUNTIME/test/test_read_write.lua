os.execute("rm -f _*.bin")
require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Vector = require 'libvec' 
local ffi = require 'Q/UTILS/lua/q_ffi'

local tests = {} 

tests.t1 = function()
  local num_elements = 64*64*1024
  local iter = 1024
  for i=1, iter do
    print("Iteration: "..tostring(i))
    local y = Vector.new('I4')
    --print("writing meta data of new vector ")
    --print("================================================")
    --M = loadstring(y:meta())(); for k, v in pairs(M) do print(k, v) end
    --print("================================================")
    assert(y:check())

    local S = {}
    for j = 1, num_elements do
      --print("Element: "..tostring(j))
      local status = y:set(j*10, j-1)
      assert(status)
      assert(y:check())
    end

    y:eov()
    assert(y:check())

    for j=0, y:num_elements()-1 do
      local ret_addr, ret_len, ret_val  = y:get(j, 1)
      local str = ffi.cast("int32_t *", ret_addr)
      assert(str[0] == (j+1)*10)
    end

  -- Explicit call to garbage collection
  --print("Calling Garbage Collector")
  --collectgarbage()
  end
  print("Successfully completed test t1")
end
--==========================================

return tests