vec = require 'libvec' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 

for i = 1,10000000 do
  x = Scalar.new(123, "F4")
  y = Scalar.new(456, "F4")
  z = Scalar.add(x, y)
  z = x + y
  w = (z == Scalar.new(579, "F4"))
assert(w == true)
end
print( "SUCCESS for ", arg[0])
