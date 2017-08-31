vec = require 'libvec' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 

-- y  = Scalar(123, "F4")
x  = Scalar.new(123, "F4")

a = Scalar.to_num(x)
assert(a == 123)
assert(tostring(x) == "123.000000")
assert(Scalar.to_str(x) == "123.000000")
-- x  = Scalar.new(123, "F4")
y  = Scalar.new("123", "I4")
-- z  = Scalar.eq(x, y)
z = (x == y)
assert(z == true)
w  = (x == Scalar.new("1234", "F4"))
-- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
assert(w == false)

w  = (x ~= Scalar.new("1234", "F4"))
-- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
assert(w == true)

w  = (x >= Scalar.new("1234", "F4"))
-- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
assert(w == false)

w  = (x <= Scalar.new("1234", "F4"))
-- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
assert(w == true)

print( "SUCCESS for ", arg[0])
