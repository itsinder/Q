vec = require 'Q/lib/libvec' ; 
cmem = require 'Q/lib/libcmem' ; 
Scalar = require 'Q/lib/libsclr' ; 

for i = 1,1000 do
  x = Scalar.new(123, "F4")
  y = Scalar.new(456, "F4")
  z = Scalar.add(x, y)
  z = x + y
  w = (z == Scalar.new(579, "F4"))
  assert(w == true)

  z = Scalar.sub(y, x)
  w = (z == Scalar.new(333, "F4"))
  assert(w == true)
end
print( "SUCCESS for ", arg[0])
