cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 

s8 = Scalar.new("9223372036854775807", "I8")
s1 = Scalar.new("-1", "I8")
s2 = Scalar.add(s8, s1)
--========
s2 = s8 + s1
y = s2:to_str("I8")
assert(y == "9223372036854775806")
--========
s2 = s8 - Scalar.new("1", "I8")
y = s2:to_str("I8")
assert(y == "9223372036854775806")
--========
print("Completed ", arg[0])
--================
