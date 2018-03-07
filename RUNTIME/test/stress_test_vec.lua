local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
require 'Q/UTILS/lua/strict'
-- for k, v in pairs(vec) do print(k, v) end 
local tests = {} 

tests.t1 = function()
  local num_trials = 1000000
  local buf = cmem.new(4096, "I4")
  for i = 1, num_trials do 
    -- create a nascent vector many times
    local y = Vector.new('I4')
    assert(y:check())
    local num_elements = 100000
    for j = 1, num_elements do 
      local s1 = Scalar.new(j, "I4")
      y:put1(s1)
      assert(y:check())
    end
    y:eov()
    assert(y:check())
    if ( ( i % 10 ) == 0 ) then print("Iter ", i)  end
  end
  print("Successfully completed test t1")
end

return tests
