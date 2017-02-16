--local chronos = require("chronos")
   local ffi  = require("ffi")
   ffi.cdef [[
   double add( int A, float B);
   ]]

local c = ffi.load("/home/indra/luatest/playground/bindings/lua/luadc/libtest.so")
local bench = function(name, func, loops)
   loops=loops or 1000
   local q0 = os.clock()
   local total = 0 
   for i=1,loops do
      total = total + func()
   end
   local q1 = os.clock()
   local time = q1*1.0 - q0
   print(total)
   print (name .. " took " .. time/loops)
end
local ffiFunction = function()
   return c.add(1,1)
   --print(c.add(1,1))
end

--ffiFunction()
bench( "FFI" , ffiFunction, 1000*1000*1000)
