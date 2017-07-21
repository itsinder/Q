vec = require 'libtest' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
x  = Scalar.new(123, "F4")
y  = Scalar.new("123", "F4")
z  = Scalar.eq(x, y)
print(z)
w  = Scalar.eq(x, Scalar.new("1234", "F4"))
print(w)
