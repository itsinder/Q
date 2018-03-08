local vec = require 'libvec' ; 
local cmem = require 'libcmem' ; 
local Scalar = require 'libsclr' ; 

local tests = {}

tests.t1 = function ()
  for i = 1,1000 do
    local x = Scalar.new(123, "F4")
    local y = Scalar.new(456, "F4")
    local z = Scalar.add(x, y)
    z = x + y
    local w = (z == Scalar.new(579, "F4"))
    assert(w == true)

    z = Scalar.sub(y, x)
    w = (z == Scalar.new(333, "F4"))
    assert(w == true)
  end
  print("Successfully completed test t1")
end

return tests
