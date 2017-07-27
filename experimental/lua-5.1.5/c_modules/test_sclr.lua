vec = require 'libvec' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
num_trials = 32 -- 1024
tbl_size = 4096 -- 1048576
sb = Scalar.new("true", "B1")
sb = Scalar.new(true, "B1")
print(sb)
x = Scalar.to_str(sb)
assert(x == "true")
sb = Scalar.new("false", "B1")
print(sb)
x = Scalar.to_str(sb)
assert(x == "false")

s1 = Scalar.new(123, "I4")
s2 = Scalar.new(123, "F4")
s3 = Scalar.new(123.1, "F4")
-- Verify that cdata works TODO
local x = s1:cdata()
y = x:print("I4")
assert(tonumber(y) == 123)
--================
assert((Scalar.eq(s1, s2)) == true)
assert((Scalar.eq(s1, s3)) == false)
for i = 1, num_trials do
  x = {}
  for j = 1, tbl_size do
    in_val = i+j/10.0;
    x[j] = Scalar.new(in_val, "F4")
    out_str = Scalar.to_str(x[j])
    out_val = tonumber(out_str)
    -- print(in_val, out_val)
    assert( math.abs((out_val - in_val))/out_val < 0.001)
  end
end
print("Completed ", arg[0])
