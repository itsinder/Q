-- T = require 'test_gc'
-- T.t2(10000)
-- T.t1(10000)
-- T.t3(10000)
-- T.t4()
local T = require 'test_dnn'
local t1 = T.t1
local bsz = 65536
repeat 
  for i = 1, 3 do 
    print("bsz/i = ", bsz, i)
    t1(bsz)
  end
  bsz = bsz / 2 
  print("---------------------------------------")
until bsz < 1 
