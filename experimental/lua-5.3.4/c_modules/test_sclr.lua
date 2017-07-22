vec = require 'libvec' ; 
cmem = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
num_trials = 1024
tbl_size = 1048576
s1 = Scalar.new(123, "I4")
s2 = Scalar.new(123, "F4")
s3 = Scalar.new(123.1, "F4")
print(Scalar.eq(s1, s2))
print(Scalar.eq(s1, s3))
os.exit()
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
  print("i = ", i)
end
print("Completed ", arg[0])
