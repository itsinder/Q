cmem   = require 'libcmem' ; 
Scalar = require 'libsclr' ; 
num_trials = 32 -- 1024
tbl_size = 4096 -- 1048576
local tests = {}
tests.t1 = function()
  -- create boolean scalars in several different ways
  sb = Scalar.new("true", "B1")
  sb = Scalar.new(true, "B1")
  x = Scalar.to_str(sb)
  assert(x == "true")
  sb = Scalar.new("false", "B1")
  assert(Scalar.to_str(sb) == "false")
  assert(sb:fldtype() == "B1")
  print("test 1 passed")
end

--================
tests.t2 = function()
  -- create integer and floating point scalars
  s1 = Scalar.new(123, "I4")
  assert(Scalar.to_num(s1) == 123)

  s2 = Scalar.new("123", "F4")
  assert(Scalar.to_num(s2) == 123)

  s3 = Scalar.new(123.456, "F8")
  assert(Scalar.to_num(s3) == 123.456)
  -- Verify that cdata works 
  local x = s1:cdata()
  print(type(x) )
  assert(type(x) == "CMEM")
  -- TODO y = x:to_str(x, "I4")
  -- TODO assert(y == "123")
  --================
  assert(Scalar.eq(s1, s2) == true)
  assert(Scalar.eq(s1, s3) == false)
  print("test 2 passed")
end

tests.t3 = function()
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
  print("test 3 passed")
end
tests.t4 = function()
  -- testing userdata and creation of scalar from pointer
  qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
  for _, qtype in ipairs(qtypes) do
    local s = Scalar.new(123, qtype)
    local x = s:cdata()
    local t = Scalar.new(x, qtype)
    assert(Scalar.eq(s, t) == true)
  end
  print("test 4 passed")
end
return tests

