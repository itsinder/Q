os.execute("rm -f _*.bin")
local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
require 'Q/UTILS/lua/strict'
-- for k, v in pairs(vec) do print(k, v) end 
local tests = {} 
-- 
tests.t1 = function()
  local num_trials = 1000000
  for i = 1, num_trials do 
    -- create a nascent vector a bit at a time
    local y = Vector.new('B1')
    assert(y:check())
    local num_elements = 100000
    for j = 1, num_elements do 
      local bval = nil
      if ( ( j % 2 ) == 0 ) then bval = true else bval = false end
      local s1 = Scalar.new(bval, "B1")
      y:put1(s1)
      assert(y:check())
    end
    y:eov()
    assert(y:check())
    print("Iter = ", i)
  end
  print("Successfully completed test t1")
end

return tests