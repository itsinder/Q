cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
num_trials = 32 -- 1024
tbl_size = 4096 -- 1048576
sb = Scalar.new("true", "B1")
sb = Scalar.new(true, "B1")
x = Scalar.to_str(sb)
assert(x == "true")
sb = Scalar.new("false", "B1")
assert(Scalar.to_str(sb) == "false")
assert(sb:fldtype() == "B1")

--================
s1 = Scalar.new(123, "I4")
s2 = Scalar.new(123, "F4")
s3 = Scalar.new(123.456, "F8")
-- Verify that cdata works 
local x = s1:cdata()
assert(type(x) == "userdata")
-- TODO FIX y = x:print("I4")
-- TODO FIX assert(tonumber(y) == 123)

x = s3:cdata()
-- TODO FIX y = x:print("F8")
-- TODO FIX assert(tonumber(y) == 123.456)
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
    assert( math.abs((out_val - in_val))/out_val < 0.001)
  end
end
print("Completed ", arg[0])
