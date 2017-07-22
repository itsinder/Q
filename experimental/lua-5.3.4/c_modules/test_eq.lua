vec = require 'libtest' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 

-- y  = Scalar(123, "F4")
x  = Scalar.new(123, "F4")

a = Scalar.to_num(x)
print(a)
print(tostring(x))
print(Scalar.to_str(x))
-- x  = Scalar.new(123, "F4")
y  = Scalar.new("123", "I4")
-- z  = Scalar.eq(x, y)
z = (x == y)
print("z = ", z)
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
