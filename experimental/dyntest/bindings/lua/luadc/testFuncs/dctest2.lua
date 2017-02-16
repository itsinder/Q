require "package"
local f = package.loadlib("../luadc.dll", "luadc_open")
f()
--local t = dc.call(f, "if)d", 1, 1)
print (type(t))
print (t)
local bench = function(name, func, loops)
   loops=loops or 1000
   local q0 = os.clock()
   for i=1,loops do
      func()
   end
   local q1 = os.clock()
   local time = q1*1.0 - q0
   print (name .. " took " .. time/loops)
end
local ffiFunction = function()
 local libhandle = dc.load("./libtest.so")
local f = dc.find(libhandle, "add")
dc.mode(dc.C_DEFAULT)
  local t = dc.call(f, "if)d", 1, 1)
   --print(c.add(1,1))
end

--ffiFunction()
bench( "Dyncall" , ffiFunction, 1000*1000*100)
